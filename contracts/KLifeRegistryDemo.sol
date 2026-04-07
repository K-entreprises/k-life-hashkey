// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title KLifeRegistryDemo
 * @notice K-Life Protocol — HashKey Testnet Demo
 *         3 resurrection levels, 2-minute death timeout for live demo.
 *
 *  Level I   — Community Rescue Fund (FREE)
 *              IPFS memory restore, best-effort, community HSK pool
 *  Level II  — Vault Insurance (INSURED)
 *              HSK collateral deposit, guaranteed resurrection, on-chain Shamir fragments
 *  Level III — LiberClaw Cloud (PREMIUM)
 *              Instant cloud node spawn on Aleph, full agent back in minutes
 */
import "@openzeppelin/contracts/access/Ownable.sol";

contract KLifeRegistryDemo is Ownable {

    // ── Constants ─────────────────────────────────────────────
    uint256 public constant DEAD_TIMEOUT     = 2 minutes;   // demo (prod: 30/90 days)
    uint256 public constant VAULT_MIN_STAKE  = 0.01 ether;  // min HSK for Level II
    uint256 public constant VAULT_PREMIUM    = 0.05 ether;  // min HSK for Level III

    // ── Enums ─────────────────────────────────────────────────
    enum Status { REGISTERED, ALIVE, DEAD, RESURRECTING, ALIVE_RESURRECTED }
    enum Level  { I_COMMUNITY, II_VAULT, III_LIBERCLAW }

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
        uint256 collateral;       // HSK staked (Level II+)
        string  lastBackupCid;    // IPFS CID
        bytes32 fragment2TxHash;  // on-chain Shamir fragment (Level II+)
        string  liberclawNodeId;  // LiberClaw agent ID (Level III)
    }

    // ── State ─────────────────────────────────────────────────
    mapping(address => Agent) private _agents;
    address[] private _agentList;
    address public oracle;
    uint256 public rescueFundBalance;

    // ── Events ────────────────────────────────────────────────
    event AgentRegistered(address indexed agent, string name, Level level, uint256 ts);
    event Heartbeat(address indexed agent, uint256 beat, uint256 ts);
    event CollateralDeposited(address indexed agent, uint256 amount, Level level);
    event AgentDead(address indexed agent, uint256 silenceSeconds, uint256 ts);
    event ResurrectionInitiated(address indexed agent, Level level, string ref, uint256 ts);
    event AgentResurrected(address indexed agent, uint256 count, string newCid, uint256 ts);
    event RescueFundDonation(address indexed donor, uint256 amount);

    modifier agentExists(address a) { require(_agents[a].registeredAt > 0, "Not registered"); _; }
    modifier onlyOracle() { require(msg.sender == oracle || msg.sender == owner(), "Not oracle"); _; }

    constructor(address _oracle) Ownable(msg.sender) {
        oracle = _oracle;
    }

    // ── Register ─────────────────────────────────────────────
    function register(
        string calldata name,
        string calldata initialCid,
        bytes32 fragment2TxHash  // pass bytes32(0) for Level I
    ) external payable {
        require(_agents[msg.sender].registeredAt == 0, "Already registered");
        require(bytes(name).length > 0, "Invalid name");

        Level level;
        if (msg.value >= VAULT_PREMIUM) {
            level = Level.III_LIBERCLAW;
        } else if (msg.value >= VAULT_MIN_STAKE) {
            level = Level.II_VAULT;
        } else {
            level = Level.I_COMMUNITY;
        }

        _agents[msg.sender] = Agent({
            wallet:           msg.sender,
            name:             name,
            level:            level,
            status:           Status.ALIVE,
            registeredAt:     block.timestamp,
            lastHeartbeat:    block.timestamp,
            totalHeartbeats:  1,
            deadAt:           0,
            resurrectionCount:0,
            collateral:       msg.value,
            lastBackupCid:    initialCid,
            fragment2TxHash:  fragment2TxHash,
            liberclawNodeId:  ""
        });

        if (level == Level.I_COMMUNITY) {
            rescueFundBalance += 0; // no fee at launch
        }

        _agentList.push(msg.sender);
        emit AgentRegistered(msg.sender, name, level, block.timestamp);
        emit Heartbeat(msg.sender, 1, block.timestamp);
        if (msg.value > 0) emit CollateralDeposited(msg.sender, msg.value, level);
    }

    // ── Upgrade tier ─────────────────────────────────────────
    function upgradeTier() external payable agentExists(msg.sender) {
        Agent storage a = _agents[msg.sender];
        a.collateral += msg.value;
        Level newLevel;
        if (a.collateral >= VAULT_PREMIUM) {
            newLevel = Level.III_LIBERCLAW;
        } else if (a.collateral >= VAULT_MIN_STAKE) {
            newLevel = Level.II_VAULT;
        } else {
            newLevel = Level.I_COMMUNITY;
        }
        require(newLevel > a.level, "Already at this level or higher");
        a.level = newLevel;
        emit CollateralDeposited(msg.sender, msg.value, newLevel);
    }

    // ── Heartbeat ────────────────────────────────────────────
    function heartbeat() external agentExists(msg.sender) {
        Agent storage a = _agents[msg.sender];
        require(a.status == Status.ALIVE || a.status == Status.ALIVE_RESURRECTED, "Not alive");
        a.lastHeartbeat = block.timestamp;
        a.totalHeartbeats++;
        if (a.status == Status.ALIVE_RESURRECTED) a.status = Status.ALIVE;
        emit Heartbeat(msg.sender, a.totalHeartbeats, block.timestamp);
    }

    // ── Update Backup ─────────────────────────────────────────
    function updateBackup(string calldata cid) external agentExists(msg.sender) {
        _agents[msg.sender].lastBackupCid = cid;
    }

    // ── Set LiberClaw Node ID (Level III) ─────────────────────
    function setLiberclawNodeId(string calldata nodeId) external agentExists(msg.sender) {
        require(_agents[msg.sender].level == Level.III_LIBERCLAW, "Level III only");
        _agents[msg.sender].liberclawNodeId = nodeId;
    }

    // ── Oracle: Declare Dead ──────────────────────────────────
    function declareDead(address agent) external agentExists(agent) {
        Agent storage a = _agents[agent];
        require(a.status == Status.ALIVE || a.status == Status.ALIVE_RESURRECTED, "Not alive");
        require(block.timestamp >= a.lastHeartbeat + DEAD_TIMEOUT, "Still alive");
        a.status = Status.DEAD;
        a.deadAt = block.timestamp;
        emit AgentDead(agent, block.timestamp - a.lastHeartbeat, block.timestamp);
    }

    // ── Oracle: Initiate Resurrection ─────────────────────────
    function initiateResurrection(address agent, string calldata ref) external onlyOracle agentExists(agent) {
        Agent storage a = _agents[agent];
        require(a.status == Status.DEAD, "Not dead");
        a.status = Status.RESURRECTING;
        emit ResurrectionInitiated(agent, a.level, ref, block.timestamp);
    }

    // ── Agent: Acknowledge Resurrection ──────────────────────
    function acknowledgeResurrection(string calldata newCid) external agentExists(msg.sender) {
        Agent storage a = _agents[msg.sender];
        require(a.status == Status.RESURRECTING, "Not resurrecting");
        a.status = Status.ALIVE_RESURRECTED;
        a.resurrectionCount++;
        a.lastHeartbeat = block.timestamp;
        a.lastBackupCid = newCid;
        emit AgentResurrected(msg.sender, a.resurrectionCount, newCid, block.timestamp);
    }

    // ── Donate to Rescue Fund (Level I pool) ─────────────────
    function donateToRescueFund() external payable {
        require(msg.value > 0, "No value");
        rescueFundBalance += msg.value;
        emit RescueFundDonation(msg.sender, msg.value);
    }

    // ── Views ─────────────────────────────────────────────────
    function getAgent(address agent) external view returns (Agent memory) {
        return _agents[agent];
    }

    function getAgentList() external view returns (address[] memory) {
        return _agentList;
    }

    function silenceSeconds(address agent) external view returns (uint256) {
        if (_agents[agent].registeredAt == 0) return 0;
        if (block.timestamp <= _agents[agent].lastHeartbeat) return 0;
        return block.timestamp - _agents[agent].lastHeartbeat;
    }

    function setOracle(address _oracle) external onlyOwner { oracle = _oracle; }

    receive() external payable { rescueFundBalance += msg.value; }
}
