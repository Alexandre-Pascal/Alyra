# Test du Contrat de Vote

## Structure des Tests

Les tests sont organisés par états du contrat et comprennent les sections suivantes :

### 1. Initialisation
- **Vérification de l'état initial** : Confirme que le contrat commence dans l'état `RegisteringVoters` (0).
- **Accès non autorisé** : S'assure que les non-votants ne peuvent pas accéder aux informations des électeurs.

### 2. État RegisteringVoters
- **Ajout de votants** : Vérifie que seuls les propriétaires peuvent ajouter des votants et qu'un votant ne peut pas être ajouté deux fois.
- **Événements** : Confirme que l'événement `VoterRegistered` est émis lors de l'ajout d'un votant.

### 3. État ProposalsRegistrationStarted
- **Ajout de propositions** : S'assure que seuls les votants peuvent ajouter des propositions.
- **Validation des propositions** : Vérifie que les propositions doivent avoir une description non vide et qu'une proposition peut être ajoutée avec succès.
- **Événements** : Vérifie que l'événement `ProposalRegistered` est émis lors de l'ajout d'une proposition.

### 4. État ProposalsRegistrationEnded
- **Gestion des états** : Vérifie que le propriétaire peut changer d'état et que des erreurs sont levées si les conditions ne sont pas remplies.

### 5. État VotingSessionStarted
- **Vote** : S'assure que les votants peuvent voter et que les règles de vote sont respectées (voter une seule fois, etc.).
- **Événements** : Vérifie que l'événement `Voted` est émis lors d'un vote.

### 6. État VotingSessionEnded
- **Changement d'état** : Vérifie que le propriétaire peut changer l'état et que le changement d'état ne peut pas se produire dans un état incorrect.

### 7. État VotesTallied
- **Comptage des votes** : S'assure que le propriétaire peut compter les votes et que le résultat est correct.
- **Événements** : Vérifie que l'événement `WorkflowStatusChange` est émis lors du changement d'état.
