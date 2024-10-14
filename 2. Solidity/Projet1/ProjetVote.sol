// SPDX-License-Identifier: MIT
//Projet commencé à 17h30 fini a 100% 21h15
//Est ce que l'administrateur peut revenir à une étape précédente ? ("si ce n'est pas précisé, ce n'est pas demandé", donc je pars du principe que non), ça permet de limiter les fonctions affichées
pragma solidity 0.8.28;

import "@openzeppelin/contracts/access/Ownable.sol";

contract Voting is Ownable {

    constructor() Ownable(msg.sender){
        // Initialisation des noms des étapes du workflow
        workflowText[WorkflowStatus.RegisteringVoters] = "Registering Voters";
        workflowText[WorkflowStatus.ProposalsRegistrationStarted] = "Proposals Registration Started";
        workflowText[WorkflowStatus.ProposalsRegistrationEnded] = "Proposals Registration Ended";
        workflowText[WorkflowStatus.VotingSessionStarted] = "Voting Session Started";
        workflowText[WorkflowStatus.VotingSessionEnded] = "Voting Session Ended";
        workflowText[WorkflowStatus.VotesTallied] = "Votes Tallied";
    }

    event VoterRegistered(address voterAddress);
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);
    event ProposalRegistered(uint proposalId);
    event Voted (address voter, uint proposalId);

    struct Voter { 
        bool isRegistered; 
        bool hasVoted; 
        uint votedProposalId; 
    } 

    struct Proposal { 
        string description; 
        uint voteCount; 
    }

    struct Vote {
        address addr;
        uint vote;
    }

    enum WorkflowStatus { 
        RegisteringVoters, 
        ProposalsRegistrationStarted, 
        ProposalsRegistrationEnded, 
        VotingSessionStarted, 
        VotingSessionEnded, 
        VotesTallied 
    }

    modifier VoterWhitelisted{
        require(whitelist[msg.sender].isRegistered || msg.sender == owner(), "You are not whitelisted");
        _;
    }

    modifier RightStep(WorkflowStatus _status){
        require(workflow == _status, "You cannot do this right now");
        _;
    }

    mapping (WorkflowStatus => string) workflowText;
    WorkflowStatus workflow;

    Proposal[] proposals;

    Vote[] votes;

    mapping (address => Voter) whitelist;

    Proposal[] winners;

    // Récupère les votes effectués jusqu'à présent
    function getVotes() external view VoterWhitelisted returns (Vote[] memory) {
        return votes;
    }

    // Enregistre un nouvel électeur dans la whitelist
    function registerVoter(address _addr) external onlyOwner RightStep(WorkflowStatus.RegisteringVoters) {
        whitelist[_addr].isRegistered = true;
        emit VoterRegistered(msg.sender);
    }

    //Permet à l'électeur de connaître l'étape actuelle du processus de vote
    function currentWorkflowStep() external view returns (string memory) {
        return workflowText[WorkflowStatus(uint(workflow))];
    }

    // Passe à l'étape suivante du workflow (seulement pour l'administrateur)
    function nextWorkflowStep() external onlyOwner returns(string memory) {
        require(uint(workflow) < uint(WorkflowStatus.VotesTallied), "Workflow is already at the final stage");
        workflow = WorkflowStatus(uint(workflow) + 1);
        emit WorkflowStatusChange(WorkflowStatus(uint(workflow) - 1), workflow);
        return workflowText[WorkflowStatus(uint(workflow))];
    }
    
    // Permet de revenir à l'étape précédente (seulement pour l'administrateur)
    function previousWorkflowStep() public onlyOwner returns(string memory) {
        require(uint(workflow) > uint(WorkflowStatus.RegisteringVoters), "Workflow is already at the initial stage");
        workflow = WorkflowStatus(uint(workflow) - 1);
        emit WorkflowStatusChange(WorkflowStatus(uint(workflow) + 1), workflow);
        return workflowText[WorkflowStatus(uint(workflow))];
    }

    // Enregistre une nouvelle proposition dans le système (pendant la phase de dépôt des propositions)
    function registerProposal(string memory _description) external VoterWhitelisted RightStep(WorkflowStatus.ProposalsRegistrationStarted) {
        require(bytes(_description).length > 0, "Proposal description cannot be empty");
        proposals.push(Proposal(_description, 0));
        emit ProposalRegistered(indexOf(_description));
    }

    // Récupère toutes les propositions enregistrées
    function getProposals() external view VoterWhitelisted returns (Proposal[] memory) {
        return proposals;
    }

    // Permet à un électeur de voter pour une proposition donnée
    function vote(uint _indexOfProposal) external VoterWhitelisted RightStep(WorkflowStatus.VotingSessionStarted) {
        // On vérifie que l'électeur n'a pas déjà voté
        require(!whitelist[msg.sender].hasVoted, "You already Voted");
        // Incrémenter le nombre de votes pour la proposition
        proposals[_indexOfProposal - 1].voteCount++;
        whitelist[msg.sender].hasVoted = true;
        // Ajouter ce vote à la liste des votes
        votes.push(Vote(msg.sender, _indexOfProposal));
        emit Voted(msg.sender, _indexOfProposal);
    }

    // Calcule les gagnants à la fin de la session de vote
    function calculateWinners() external onlyOwner RightStep(WorkflowStatus.VotingSessionEnded) returns (Proposal[] memory) {
        uint maxVoteCount = 0;

        for (uint i = 0; i < proposals.length; i++) {
            if (proposals[i].voteCount > maxVoteCount) {
                maxVoteCount = proposals[i].voteCount;
                // Réinitialise la liste des gagnants si une nouvelle proposition a plus de voix
                delete winners;
                winners.push(proposals[i]);
            } else if (proposals[i].voteCount == maxVoteCount) {
                // Si plusieurs propositions ont le même nombre de votes, on les ajoute
                winners.push(proposals[i]);
            }
        }
        return winners;
    }

    // Récupère les gagnants après le calcul des votes
    function getWinners() external view VoterWhitelisted RightStep(WorkflowStatus.VotesTallied) returns (Proposal[] memory) {
        return winners;
    }

    // Trouve l'index d'une proposition donnée en fonction de sa description
    function indexOf(string memory searchFor) private view returns (uint256) {
        for (uint256 i = 0; i < proposals.length; i++) {
            if (keccak256(bytes(proposals[i].description)) == keccak256(bytes(searchFor))) {
                return i;
            }
        }
        revert("Not Found");
    }
}
