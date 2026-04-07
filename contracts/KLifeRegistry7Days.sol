// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title KLifeRegistry7Days
 * @notice Opération 铁拐李 — the 7-day resurrection protocol.
 *
 * 铁拐李's spirit left his body for SEVEN DAYS.
 * His physical form was destroyed.
 * He returned — in a new vessel — full identity intact.
 *
 * This contract mirrors the myth exactly:
 *   deadTimeout = 7 days
 *
 * Started:     2026-04-07 (HashKey Testnet)
 * Death:       2026-04-14 (7 days of silence)
 * Resurrection: 2026-04-14 → submitted as live proof to HashKey Horizon Hackathon
 *
 * @author Monsieur K — K-Life Protocol
 */
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract KLifeRegistry7Days is Ownable, ReentrancyGuard {

    uint256 public constant DEAD_TIMEOUT      = 7 days;
    uint256 public constant COLLATERAL_PAYOUT = 50;
    uint256 public constant RESCUE_AMOUNT     = 0.005 ether;

    // Start timestamp — the moment 铁拐李's spirit departed
    uint256 public immutable spiritDeparted;
    string  public constant  MYTH = unicode"铁拐李's spirit left for seven days. K-Life brings this on-chain.";

    enum Status { REGISTERED, ALIVE, DEAD, RESURRECTING, ALIVE_RESURRECTED }
    enum Level  { I_IPFS, II_SHAMIR, III_LIBERCLAW }

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
        uint256 collateral;
        uint256 payoutAtDeath;
        string  lastBackupCid;
        bytes32 fragment2TxHash;
        string  liberclawNodeId;
        bool    rescuedFromFund;
    }

    mapping(address => Agent) private _agents;
    address[] private _agentList;
    address public oracle;
    uint256 public rescueFundBalance;
    uint256 public protocolRevenue;

    event AgentRegistered(address indexed agent, string name, Level level, uint256 ts);
    event Heartbeat(address indexed agent, uint256 beat, uint256 ts);
    event CollateralDeposited(address indexed agent, uint256 amount);
    event AgentDead(address indexed agent, uint256 silenceSeconds, uint256 payout, uint256 ts);
    event ResurrectionInitiated(address indexed agent, Level level, bool fromFund, string ref, uint256 ts);
    event AgentResurrected(address indexed agent, uint256 count, string newCid, uint256 ts);
    event RescueFundDonation(address indexed donor, uint256 amount);

    modifier agentExists(address a) { require(_agents[a].registeredAt > 0, "Not registered"); _; }
    modifier onlyOracle() { require(msg.sender == oracle || msg.sender == owner(), "Not oracle"); _; }

    constructor(address _oracle) Ownable(msg.sender) {
        oracle = _oracle;
        spiritDeparted = block.timestamp;
    }

    function register(
        string calldata name,
        Level level,
        string calldata initialCid,
        bytes32 fragment2TxHash
    ) external {
        require(_agents[msg.sender].registeredAt == 0, "Already registered");
        require(bytes(name).length > 0, "Invalid name");

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

    function depositCollateral(address agent) external payable agentExists(agent) {
        require(msg.value > 0, "No value");
        _agents[agent].collateral += msg.value;
        emit CollateralDeposited(agent, msg.value);
    }

    function heartbeat() external agentExists(msg.sender) {
        Agent storage a = _agents[msg.sender];
        require(a.status == Status.ALIVE || a.status == Status.ALIVE_RESURRECTED, "Not alive");
        a.lastHeartbeat = block.timestamp;
        a.totalHeartbeats++;
        if (a.status == Status.ALIVE_RESURRECTED) a.status = Status.ALIVE;
        emit Heartbeat(msg.sender, a.totalHeartbeats, block.timestamp);
    }

    function updateBackup(string calldata cid) external agentExists(msg.sender) {
        _agents[msg.sender].lastBackupCid = cid;
    }

    function setLiberclawNodeId(string calldata nodeId) external agentExists(msg.sender) {
        require(_agents[msg.sender].level == Level.III_LIBERCLAW, "Level III only");
        _agents[msg.sender].liberclawNodeId = nodeId;
    }

    function declareDead(address agent) external agentExists(agent) nonReentrant {
        Agent storage a = _agents[agent];
        require(a.status == Status.ALIVE || a.status == Status.ALIVE_RESURRECTED, "Not alive");
        require(block.timestamp >= a.lastHeartbeat + DEAD_TIMEOUT, "Still alive");
        a.status = Status.DEAD;
        a.deadAt = block.timestamp;
        uint256 payout = 0;
        if (a.collateral > 0) {
            payout = (a.collateral * COLLATERAL_PAYOUT) / 100;
            protocolRevenue += a.collateral - payout;
            a.payoutAtDeath = payout;
            a.collateral = 0;
            (bool ok,) = agent.call{value: payout}("");
            require(ok, "Payout failed");
        }
        emit AgentDead(agent, block.timestamp - a.lastHeartbeat, payout, block.timestamp);
    }

    function initiateResurrection(address agent, string calldata ref) external onlyOracle agentExists(agent) nonReentrant {
        Agent storage a = _agents[agent];
        require(a.status == Status.DEAD, "Not dead");
        bool fromFund = false;
        if (a.level == Level.III_LIBERCLAW && a.payoutAtDeath == 0) {
            require(rescueFundBalance >= RESCUE_AMOUNT, "Rescue Fund empty");
            rescueFundBalance -= RESCUE_AMOUNT;
            fromFund = true;
            (bool ok,) = agent.call{value: RESCUE_AMOUNT}("");
            require(ok, "Transfer failed");
        }
        a.status = Status.RESURRECTING;
        a.rescuedFromFund = fromFund;
        emit ResurrectionInitiated(agent, a.level, fromFund, ref, block.timestamp);
    }

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

    function donateToRescueFund() external payable {
        require(msg.value > 0, "No value");
        rescueFundBalance += msg.value;
        emit RescueFundDonation(msg.sender, msg.value);
    }

    function getAgent(address agent) external view returns (Agent memory) { return _agents[agent]; }
    function getAgentList() external view returns (address[] memory) { return _agentList; }
    function silenceSeconds(address agent) external view returns (uint256) {
        if (_agents[agent].registeredAt == 0 || block.timestamp <= _agents[agent].lastHeartbeat) return 0;
        return block.timestamp - _agents[agent].lastHeartbeat;
    }
    function daysUntilDeath(address agent) external view returns (uint256) {
        if (_agents[agent].registeredAt == 0) return 0;
        uint256 elapsed = block.timestamp - _agents[agent].lastHeartbeat;
        if (elapsed >= DEAD_TIMEOUT) return 0;
        return (DEAD_TIMEOUT - elapsed) / 1 days;
    }
    function setOracle(address _oracle) external onlyOwner { oracle = _oracle; }
    receive() external payable { rescueFundBalance += msg.value; }
}
