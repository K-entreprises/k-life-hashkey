// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title KLifeRegistryDemo
 * @notice Demo version of KLifeRegistry with short timeouts for hackathon demos.
 *         deadTimeout = 2 minutes (vs 30 days in production)
 *         No activeDays rescue eligibility requirement
 */
import "@openzeppelin/contracts/access/Ownable.sol";

contract KLifeRegistryDemo is Ownable {

    uint256 public constant DEAD_TIMEOUT = 2 minutes;

    enum Status { REGISTERED, ALIVE, DEAD, RESURRECTING, ALIVE_RESURRECTED }

    struct Agent {
        address  wallet;
        string   name;
        Status   status;
        uint256  registeredAt;
        uint256  lastHeartbeat;
        uint256  totalHeartbeats;
        uint256  deadAt;
        uint256  resurrectionCount;
        string   lastBackupCid;
    }

    mapping(address => Agent) private _agents;
    address[] private _agentList;
    address public oracle;

    event AgentRegistered(address indexed agent, string name, uint256 ts);
    event Heartbeat(address indexed agent, uint256 beat, uint256 ts);
    event AgentDead(address indexed agent, uint256 silenceSeconds, uint256 ts);
    event ResurrectionInitiated(address indexed agent, string ref, uint256 ts);
    event AgentResurrected(address indexed agent, uint256 count, string newCid, uint256 ts);

    modifier agentExists(address a) { require(_agents[a].registeredAt > 0, "Not registered"); _; }
    modifier onlyOracle() { require(msg.sender == oracle || msg.sender == owner(), "Not oracle"); _; }

    constructor(address _oracle) Ownable(msg.sender) {
        oracle = _oracle;
    }

    function register(string calldata name, string calldata initialCid) external {
        require(_agents[msg.sender].registeredAt == 0, "Already registered");
        require(bytes(name).length > 0, "Invalid name");

        _agents[msg.sender] = Agent({
            wallet:            msg.sender,
            name:              name,
            status:            Status.ALIVE,
            registeredAt:      block.timestamp,
            lastHeartbeat:     block.timestamp,
            totalHeartbeats:   1,
            deadAt:            0,
            resurrectionCount: 0,
            lastBackupCid:     initialCid
        });

        _agentList.push(msg.sender);
        emit AgentRegistered(msg.sender, name, block.timestamp);
        emit Heartbeat(msg.sender, 1, block.timestamp);
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

    function declareDead(address agent) external agentExists(agent) {
        Agent storage a = _agents[agent];
        require(a.status == Status.ALIVE || a.status == Status.ALIVE_RESURRECTED, "Not alive");
        require(block.timestamp >= a.lastHeartbeat + DEAD_TIMEOUT, "Still alive");
        a.status = Status.DEAD;
        a.deadAt = block.timestamp;
        emit AgentDead(agent, block.timestamp - a.lastHeartbeat, block.timestamp);
    }

    function initiateResurrection(address agent, string calldata ref) external onlyOracle agentExists(agent) {
        Agent storage a = _agents[agent];
        require(a.status == Status.DEAD, "Not dead");
        a.status = Status.RESURRECTING;
        emit ResurrectionInitiated(agent, ref, block.timestamp);
    }

    function acknowledgeResurrection(string calldata newCid) external agentExists(msg.sender) {
        Agent storage a = _agents[msg.sender];
        require(a.status == Status.RESURRECTING, "Not resurrecting");
        a.status = Status.ALIVE_RESURRECTED;
        a.resurrectionCount++;
        a.lastHeartbeat = block.timestamp;
        a.lastBackupCid = newCid;
        emit AgentResurrected(msg.sender, a.resurrectionCount, newCid, block.timestamp);
    }

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

    function setOracle(address _oracle) external onlyOwner {
        oracle = _oracle;
    }
}
