// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title KLifeRegistryDemo
 * @notice K-Life Protocol — HashKey Testnet Demo
 *         2-minute death timeout for live demo.
 *
 * ── Resurrection Levels (all FREE to register) ───────────────
 *
 *  Level I   — IPFS Memory Restore
 *              Memory backup restored from IPFS. Simplest form of resurrection.
 *              No funding mechanism — agent just gets its memory back.
 *
 *  Level II  — IPFS + On-chain Shamir Fragments
 *              Fragment 2 stored in chain calldata. More robust key recovery.
 *              No funding mechanism — agent gets memory + key fragments back.
 *
 *  Level III — LiberClaw Full Resurrection
 *              Complete agent respawn on Aleph Cloud node.
 *              Requires funding to pay for the new node:
 *                - If collateral was deposited → 50% released at death (automatic)
 *                - If no collateral → Rescue Fund steps in (community HSK pool)
 *
 * ── Collateral (optional, any level) ────────────────────────
 *  Any agent can deposit HSK collateral at any time.
 *  At death: 50% released to agent wallet to fund resurrection.
 *  Remaining 50% stays in contract (K-Life protocol revenue).
 *
 * @author Monsieur K — K-Life Protocol on HashKey Chain
 */
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract KLifeRegistryDemo is Ownable, ReentrancyGuard {

    // ── Constants ─────────────────────────────────────────────
    uint256 public constant DEAD_TIMEOUT        = 2 minutes;  // demo (prod: 30-90 days)
    uint256 public constant COLLATERAL_PAYOUT   = 50;         // % released at death
    uint256 public constant RESCUE_AMOUNT       = 0.005 ether; // HSK per Level III rescue

    // ── Enums ─────────────────────────────────────────────────
    enum Status { REGISTERED, ALIVE, DEAD, RESURRECTING, ALIVE_RESURRECTED }
    enum Level  { I_IPFS, II_SHAMIR, III_LIBERCLAW }

    // ── Structs ───────────────────────────────────────────────
    struct Agent {
        address wallet;
        string  name;
        Level   level;
        Status  status;
        uint256 registeredAt;
        uint256 lastHeartbeat;
        uint256 totalHeartbeats;
        uint256 deadAt;
        uint256 resurrectionCount;
        uint256 collateral;         // HSK deposited (optional)
        uint256 payoutAtDeath;      // HSK released when declared dead (50% of collateral)
        string  lastBackupCid;      // IPFS CID (all levels)
        bytes32 fragment2TxHash;    // calldata TX storing Shamir fragment (Level II+)
        string  liberclawNodeId;    // LiberClaw agent ID (Level III)
        bool    rescuedFromFund;    // true if Rescue Fund was used (Level III, no collateral)
    }

    // ── State ─────────────────────────────────────────────────
    mapping(address => Agent)   private _agents;
    address[]                   private _agentList;
    address public oracle;
    uint256 public rescueFundBalance;   // community HSK pool (for Level III, no collateral)
    uint256 public protocolRevenue;     // 50% of collateral at death

    // ── Events ────────────────────────────────────────────────
    event AgentRegistered(address indexed agent, string name, Level level, uint256 ts);
    event Heartbeat(address indexed agent, uint256 beat, uint256 ts);
    event CollateralDeposited(address indexed agent, uint256 amount, uint256 total);
    event AgentDead(address indexed agent, uint256 silenceSeconds, uint256 payoutReleased, uint256 ts);
    event ResurrectionInitiated(address indexed agent, Level level, bool fromRescueFund, string ref, uint256 ts);
    event AgentResurrected(address indexed agent, uint256 count, string newCid, uint256 ts);
    event RescueFundDonation(address indexed donor, uint256 amount);
    event LiberclawNodeSet(address indexed agent, string nodeId);

    modifier agentExists(address a) { require(_agents[a].registeredAt > 0, "Not registered"); _; }
    modifier onlyOracle() { require(msg.sender == oracle || msg.sender == owner(), "Not oracle"); _; }

    constructor(address _oracle) Ownable(msg.sender) {
        oracle = _oracle;
    }

    // ── Register — always free ────────────────────────────────
    /**
     * @param name         Agent name
     * @param level        I_IPFS | II_SHAMIR | III_LIBERCLAW
     * @param initialCid   IPFS backup CID
     * @param fragment2TxHash  TX hash storing Shamir F2 in calldata (Level II+, bytes32(0) for Level I)
     */
    function register(
        string calldata name,
        Level level,
        string calldata initialCid,
        bytes32 fragment2TxHash
    ) external {
        require(_agents[msg.sender].registeredAt == 0, "Already registered");
        require(bytes(name).length > 0 && bytes(name).length <= 64, "Invalid name");

        _agents[msg.sender] = Agent({
            wallet:            msg.sender,
            name:              name,
            level:             level,
            status:            Status.ALIVE,
            registeredAt:      block.timestamp,
            lastHeartbeat:     block.timestamp,
            totalHeartbeats:   1,
            deadAt:            0,
            resurrectionCount: 0,
            collateral:        0,
            payoutAtDeath:     0,
            lastBackupCid:     initialCid,
            fragment2TxHash:   fragment2TxHash,
            liberclawNodeId:   "",
            rescuedFromFund:   false
        });

        _agentList.push(msg.sender);
        emit AgentRegistered(msg.sender, name, level, block.timestamp);
        emit Heartbeat(msg.sender, 1, block.timestamp);
    }

    // ── Deposit collateral — optional, any time ───────────────
    /**
     * Any agent (or their owner) can deposit HSK collateral at any time.
     * At death: 50% released to agent wallet, 50% to protocol.
     */
    function depositCollateral(address agent) external payable agentExists(agent) {
        require(msg.value > 0, "No value");
        _agents[agent].collateral += msg.value;
        emit CollateralDeposited(agent, msg.value, _agents[agent].collateral);
    }

    // ── Heartbeat ─────────────────────────────────────────────
    function heartbeat() external agentExists(msg.sender) {
        Agent storage a = _agents[msg.sender];
        require(a.status == Status.ALIVE || a.status == Status.ALIVE_RESURRECTED, "Not alive");
        a.lastHeartbeat = block.timestamp;
        a.totalHeartbeats++;
        if (a.status == Status.ALIVE_RESURRECTED) a.status = Status.ALIVE;
        emit Heartbeat(msg.sender, a.totalHeartbeats, block.timestamp);
    }

    // ── Update backup CID ─────────────────────────────────────
    function updateBackup(string calldata cid) external agentExists(msg.sender) {
        _agents[msg.sender].lastBackupCid = cid;
    }

    // ── Set LiberClaw node ID (Level III) ─────────────────────
    function setLiberclawNodeId(string calldata nodeId) external agentExists(msg.sender) {
        require(_agents[msg.sender].level == Level.III_LIBERCLAW, "Level III only");
        _agents[msg.sender].liberclawNodeId = nodeId;
        emit LiberclawNodeSet(msg.sender, nodeId);
    }

    // ── Oracle: Declare Dead ──────────────────────────────────
    function declareDead(address agent) external agentExists(agent) nonReentrant {
        Agent storage a = _agents[agent];
        require(a.status == Status.ALIVE || a.status == Status.ALIVE_RESURRECTED, "Not alive");
        require(block.timestamp >= a.lastHeartbeat + DEAD_TIMEOUT, "Still alive");

        a.status = Status.DEAD;
        a.deadAt = block.timestamp;

        // Release 50% of collateral to agent wallet immediately
        uint256 payout = 0;
        if (a.collateral > 0) {
            payout = (a.collateral * COLLATERAL_PAYOUT) / 100;
            uint256 remaining = a.collateral - payout;
            a.payoutAtDeath = payout;
            a.collateral = 0;
            protocolRevenue += remaining;
            if (payout > 0) {
                (bool ok,) = agent.call{value: payout}("");
                require(ok, "Payout failed");
            }
        }

        emit AgentDead(agent, block.timestamp - a.lastHeartbeat, payout, block.timestamp);
    }

    // ── Oracle: Initiate Resurrection ─────────────────────────
    /**
     * For Level III without collateral: uses Rescue Fund.
     */
    function initiateResurrection(address agent, string calldata ref) external onlyOracle agentExists(agent) nonReentrant {
        Agent storage a = _agents[agent];
        require(a.status == Status.DEAD, "Not dead");

        bool fromFund = false;
        // Level III with no collateral payout → use Rescue Fund
        if (a.level == Level.III_LIBERCLAW && a.payoutAtDeath == 0) {
            require(rescueFundBalance >= RESCUE_AMOUNT, "Rescue Fund empty");
            rescueFundBalance -= RESCUE_AMOUNT;
            fromFund = true;
            // Send rescue amount to agent wallet to pay for LiberClaw node
            (bool ok,) = agent.call{value: RESCUE_AMOUNT}("");
            require(ok, "Rescue transfer failed");
        }

        a.status = Status.RESURRECTING;
        a.rescuedFromFund = fromFund;
        emit ResurrectionInitiated(agent, a.level, fromFund, ref, block.timestamp);
    }

    // ── Agent: Acknowledge Resurrection ──────────────────────
    function acknowledgeResurrection(string calldata newCid) external agentExists(msg.sender) {
        Agent storage a = _agents[msg.sender];
        require(a.status == Status.RESURRECTING, "Not resurrecting");
        a.status = Status.ALIVE_RESURRECTED;
        a.resurrectionCount++;
        a.lastHeartbeat = block.timestamp;
        a.lastBackupCid = newCid;
        a.payoutAtDeath = 0;
        a.rescuedFromFund = false;
        emit AgentResurrected(msg.sender, a.resurrectionCount, newCid, block.timestamp);
    }

    // ── Donate to Rescue Fund ─────────────────────────────────
    function donateToRescueFund() external payable {
        require(msg.value > 0, "No value");
        rescueFundBalance += msg.value;
        emit RescueFundDonation(msg.sender, msg.value);
    }

    // ── Views ─────────────────────────────────────────────────
    function getAgent(address agent) external view returns (Agent memory) { return _agents[agent]; }
    function getAgentList() external view returns (address[] memory) { return _agentList; }
    function silenceSeconds(address agent) external view returns (uint256) {
        if (_agents[agent].registeredAt == 0 || block.timestamp <= _agents[agent].lastHeartbeat) return 0;
        return block.timestamp - _agents[agent].lastHeartbeat;
    }
    function setOracle(address _oracle) external onlyOwner { oracle = _oracle; }
    function withdrawRevenue(address to) external onlyOwner {
        uint256 amt = protocolRevenue;
        protocolRevenue = 0;
        (bool ok,) = to.call{value: amt}("");
        require(ok, "Withdraw failed");
    }
    receive() external payable { rescueFundBalance += msg.value; }
}
