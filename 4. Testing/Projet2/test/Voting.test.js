const { expect, assert } = require('chai');
const hre = require('hardhat');

describe('Test Voting', async function () {

    let deployedContract;
    let owner, addr1, addr2;

    beforeEach(async function () {
        [owner, addr1, addr2] = await hre.ethers.getSigners();

        const Voting = await hre.ethers.deployContract('Voting');
        deployedContract = Voting;
    });
    
    describe('Initialization', async function () {
        it('Should not return voters if not a voter', async function () {
            await expect(deployedContract.getVoter(addr1.address)).to.be.revertedWith("You're not a voter");
        });

        it('Should start with RegisteringVoters state', async function () {
            const state = await deployedContract.workflowStatus();
            assert(state == 0);
        });

        it('Should not allow to revert back', async function () {
            await deployedContract.startProposalsRegistering();
            await deployedContract.endProposalsRegistering();
            await expect(deployedContract.startProposalsRegistering()).to.be.revertedWith('Registering proposals cant be started now');
        });
        
    });
        
    describe('RegisteringVoters state', async function () {
        it('Should not allow to add a voter if not in RegisteringVoters state', async function () {
            deployedContract.startProposalsRegistering();
            await expect(deployedContract.addVoter(addr1.address)).to.be.revertedWith('Voters registration is not open yet');
        });
        
        it('Should not allow to add a voter if not owner', async function () {
            await expect(deployedContract.connect(addr1).addVoter(addr1.address)).to.be.revertedWithCustomError(deployedContract, 'OwnableUnauthorizedAccount');
        });
        
        it('Should not allow to add a voter twice', async function () {
            await deployedContract.addVoter(addr1.address);
            await expect(deployedContract.addVoter(addr1.address)).to.be.revertedWith('Already registered');
        });

        it('Should add a voter', async function () {
            await deployedContract.addVoter(addr1.address);
            const voter = await deployedContract.connect(addr1).getVoter(addr1.address);
            assert(voter.isRegistered);
        });

        it('Should emit VoterRegistered event', async function () {
            await expect(deployedContract.addVoter(addr1.address))
                .to.emit(deployedContract, 'VoterRegistered')
                .withArgs(addr1.address);
        });
    });

    describe('ProposalsRegistrationStarted state', async function () {
        describe('WorkflowStatusChange event', async function () {
            it('Should fail the change of state if not owner', async function () {
                await expect(deployedContract.connect(addr1).startProposalsRegistering()).to.be.revertedWithCustomError(deployedContract, 'OwnableUnauthorizedAccount');
            });

            it('Should fail the change of state if not in RegisteringVoters state', async function () {
                await deployedContract.startProposalsRegistering();
                await deployedContract.endProposalsRegistering();
                await expect(deployedContract.startProposalsRegistering()).to.be.revertedWith('Registering proposals cant be started now');
            });

            it('Should emit WorkflowStatusChange event', async function () {
                await expect(deployedContract.startProposalsRegistering())
                    .to.emit(deployedContract, 'WorkflowStatusChange')
                    .withArgs(0, 1);
            });
        });
        
        describe('addProposal', async function () {
            beforeEach(async function () {
                await deployedContract.addVoter(owner.address);
                await deployedContract.startProposalsRegistering();
            });

            it('Should not allow getOneProposal if not a voter', async function () {
                await deployedContract.addProposal('desc');
                await expect(deployedContract.connect(addr1).getOneProposal(1)).to.be.revertedWith("You're not a voter");
            });

            it('Should not allow to add a proposal if not in ProposalsRegistrationStarted state', async function () {
                await deployedContract.endProposalsRegistering();
                await expect(deployedContract.addProposal('desc')).to.be.revertedWith('Proposals are not allowed yet');
            });

            it('Should not allow to add a proposal if not a voter', async function () {
                await expect(deployedContract.connect(addr1).addProposal('desc')).to.be.revertedWith("You're not a voter");
            });
            
            it('Should not allow to add a proposal with empty description', async function () {
                await expect(deployedContract.addProposal('')).to.be.revertedWith('Vous ne pouvez pas ne rien proposer');
            });

            it('Should add a proposal', async function () {
                await deployedContract.addProposal('desc');
                const proposal = await deployedContract.getOneProposal(1);
                assert(proposal.description == 'desc');
            });

            it('Should emit ProposalRegistered event', async function () {
                await expect(deployedContract.addProposal('desc'))
                    .to.emit(deployedContract, 'ProposalRegistered')
                    .withArgs(1);
            });
        });
    });

    describe('ProposalsRegistrationEnded state', async function () {
        beforeEach(async function () {
            await deployedContract.addVoter(owner.address);
            await deployedContract.startProposalsRegistering();
            await deployedContract.addProposal('desc');
        });

        describe('WorkflowStatusChange event', async function () {
            it('Should fail the change of state if not owner', async function () {
                await expect(deployedContract.connect(addr1).endProposalsRegistering()).to.be.revertedWithCustomError(deployedContract, 'OwnableUnauthorizedAccount');
            });

            it('Should fail the change of state if not in ProposalsRegistrationStarted state', async function () {
                await deployedContract.endProposalsRegistering();
                await expect(deployedContract.endProposalsRegistering()).to.be.revertedWith('Registering proposals havent started yet');
            });

            it('Should emit WorkflowStatusChange event', async function () {
                await expect(deployedContract.endProposalsRegistering())
                    .to.emit(deployedContract, 'WorkflowStatusChange')
                    .withArgs(1, 2);
            });
        });
    });

    describe('VotingSessionStarted state', async function () {
        beforeEach(async function () {
            await deployedContract.addVoter(owner.address);
            await deployedContract.startProposalsRegistering();
            await deployedContract.addProposal('desc');
            await deployedContract.endProposalsRegistering();
        });

        describe('WorkflowStatusChange event', async function () {
            it('Should fail the change of state if not owner', async function () {
                await expect(deployedContract.connect(addr1).startVotingSession()).to.be.revertedWithCustomError(deployedContract, 'OwnableUnauthorizedAccount');
            });

            it('Should fail the change of state if not in ProposalsRegistrationEnded state', async function () {
                await deployedContract.startVotingSession();
                await expect(deployedContract.startVotingSession()).to.be.revertedWith('Registering proposals phase is not finished');
            });

            it('Should emit WorkflowStatusChange event', async function () {
                await expect(deployedContract.startVotingSession())
                    .to.emit(deployedContract, 'WorkflowStatusChange')
                    .withArgs(2, 3);
            });
        });

        describe('setVote', async function () {
            beforeEach(async function () {
                await deployedContract.startVotingSession();
            });

            it('Should not allow to vote if not a voter', async function () {
                await expect(deployedContract.connect(addr1).setVote(1)).to.be.revertedWith("You're not a voter");
            });

            it('Should not allow to vote if not in VotingSessionStarted state', async function () {
                await deployedContract.endVotingSession();
                await expect(deployedContract.setVote(1)).to.be.revertedWith('Voting session havent started yet');
            });

            it('Should not allow to vote if already voted', async function () {
                await deployedContract.setVote(1);
                await expect(deployedContract.setVote(1)).to.be.revertedWith('You have already voted');
            });

            it('Should not allow to vote if proposal not found', async function () {
                await expect(deployedContract.setVote(2)).to.be.revertedWith('Proposal not found');
            });

            it('Should set a vote', async function () {
                await deployedContract.setVote(1);
                const voter = await deployedContract.getVoter(owner.address);
                assert(voter.hasVoted);
            });

            it('Should emit Voted event', async function () {
                await expect(deployedContract.setVote(1))
                    .to.emit(deployedContract, 'Voted')
                    .withArgs(owner.address, 1);
            });
        });
    });

    describe('VotingSessionEnded state', async function () {
        beforeEach(async function () {
            await deployedContract.addVoter(owner.address);
            await deployedContract.startProposalsRegistering();
            await deployedContract.addProposal('desc');
            await deployedContract.endProposalsRegistering();
            await deployedContract.startVotingSession();
            await deployedContract.setVote(1);
        });

        describe('WorkflowStatusChange event', async function () {
            it('Should fail the change of state if not owner', async function () {
                await expect(deployedContract.connect(addr1).endVotingSession()).to.be.revertedWithCustomError(deployedContract, 'OwnableUnauthorizedAccount');
            });

            it('Should fail the change of state if not in VotingSessionStarted state', async function () {
                await deployedContract.endVotingSession();
                await expect(deployedContract.endVotingSession()).to.be.revertedWith('Voting session havent started yet');
            });

            it('Should emit WorkflowStatusChange event', async function () {
                await expect(deployedContract.endVotingSession())
                    .to.emit(deployedContract, 'WorkflowStatusChange')
                    .withArgs(3, 4);
            });
        });
    });

    describe('VotesTallied state', async function () {
        beforeEach(async function () {
            await deployedContract.addVoter(owner.address);
            await deployedContract.addVoter(addr1.address);
            await deployedContract.addVoter(addr2.address);
            await deployedContract.startProposalsRegistering();
            await deployedContract.addProposal('desc');
            await deployedContract.addProposal('desc2');
            await deployedContract.endProposalsRegistering();
            await deployedContract.startVotingSession();
            await deployedContract.setVote(1);
            await deployedContract.connect(addr1).setVote(2);
            await deployedContract.connect(addr2).setVote(2);
            await deployedContract.endVotingSession();
        });

        describe('WorkflowStatusChange event', async function () {
            it('Should fail the change of state if not owner', async function () {
                await expect(deployedContract.connect(addr1).tallyVotes()).to.be.revertedWithCustomError(deployedContract, 'OwnableUnauthorizedAccount');
            });

            it('Should fail the change of state if not in VotingSessionEnded state', async function () {
                await deployedContract.tallyVotes();
                await expect(deployedContract.tallyVotes()).to.be.revertedWith('Current status is not voting session ended');
            });

            it('Should emit WorkflowStatusChange event', async function () {
                await expect(deployedContract.tallyVotes())
                    .to.emit(deployedContract, 'WorkflowStatusChange')
                    .withArgs(4, 5);
            });
        });

        describe('tallyVotes', async function () {
            it('Should not tally votes if not the owner', async function () {
                await expect(deployedContract.connect(addr1).tallyVotes()).to.be.revertedWithCustomError(deployedContract, 'OwnableUnauthorizedAccount');
            });

            it('Should tally votes', async function () {
                await deployedContract.tallyVotes();
                const winningProposalID = await deployedContract.winningProposalID();
                assert(winningProposalID == 2);
            });
        });
    });
});