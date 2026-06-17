![RNA-seq](https://img.shields.io/badge/RNA--seq-pipeline-blue)
![Snakemake](https://img.shields.io/badge/workflow-snakemake-green)
![Reproducible](https://img.shields.io/badge/reproducible-yes-brightgreen)

# Présentation du projet

Ce projet porte sur l'analyse de données de séquençage d'ARN (RNA-seq) issues du jeu de données public [PRJNA632023](https://www.ncbi.nlm.nih.gov/Traces/study/?acc=PRJNA632023&o=acc_s%3Aa), disponible sur la base de données NCBI SRA.

L'étude vise à caractériser les conséquences transcriptionnelles de la perte de fonction du gène SHANK3, un gène synaptique majeur impliqué dans le syndrome de Phelan-McDermid (PMS) et dans certaines formes de troubles du spectre de l'autisme.

Le modèle expérimental repose sur des cellules souches pluripotentes induites humaines (hiPSC) dérivées de patients porteurs d'altérations de SHANK3 et de témoins apparentés non affectés. Les hiPSC ont été différenciées en deux stades du développement neuronal :

- Neural Progenitor Cells (NPCs) ;
- Neurones du télencéphale (mixed forebrain neurons).

Des données de RNA-seq bulk en paired-end (Illumina) ont été générées afin de comparer les profils d'expression génique entre les individus atteints de PMS et les contrôles. L’objectif de ce projet est de traiter des données brutes de séquençage afin d’identifier les gènes différentiellement exprimés dans les conditions biologiques étudiées.

# Objectif

L’objectif principal de ce projet est de :

- Traiter les données RNA-seq brutes jusqu’à un format exploitable (matrice de comptage par gène)
- Évaluer qualité des données de séquençage
- Quantifier l’expression des gènes
- Identifier les gènes différentiellement exprimés (DEGs) entre les groupes PMS et contrôle
- Explorer les voies biologiques et les enrichissements fonctionnels associés aux changements d’expression

Ce projet vise donc à proposer un pipeline reproductible d’analyse transcriptomique et à extraire des informations biologiquement interprétables à partir des données brutes.

# Description du pipeline

Le workflow est divisé en deux parties :

## 1. Prétraitement des données RNA-seq

Les étapes de prétraitement ont été automatisées à l'aide d'un pipeline Snakemake exécuté par lots sur l'ensemble des échantillons.

Les principales étapes sont :

- Téléchargement des données FASTQ depuis le SRA ;
- Contrôle qualité avec FastQC ;
- Agrégation des rapports avec MultiQC ;
- Alignement des reads sur le génome humain de référence avec HISAT2 ;
- Comptage des reads par gène avec featureCounts.

***Exemple d'éxécution sur un échantillon***

```
# QC
fastqc sample_R1.fastq.gz sample_R2.fastq.gz 

# Alignement
hisat2 -p 4 \
-x ~/RNAseq/Index/grch38/genome \
-1 ~/RNAseq/Raw_data/Fastqc/sample_R1.fastq.gz \
-2 ~/RNAseq/Raw_data/Fastqc/sample_R2.fastq.gz \
| samtools sort -@ 4 -o ~/RNAseq/preprocessed/HISAT2_alignments/sample.bam

# Quantification
featureCounts -T 4 -p \
-a ~/RNAseq/Reference/gencode.v49.basic.annotation.gtf \
-o ~/RNAseq/Results/counts/counts.txt \
preprocessed/HISAT2_alignments/sample.bam
```

Exécution du pipeline Snakemake

L'ensemble des échantillons a été traité automatiquement par batch via :

```
snakemake -j 1 --printshellcmds
```

## 2. Analyse de l'expression différentielle

Les analyses statistiques ont ensuite été réalisées sous R à partir de la matrice de comptage générée par featureCounts.

Les principales étapes comprennent :

- Import des comptages ;
- Contrôle qualité des échantillons ;
- Filtrage des gènes faiblement exprimés ;
- Normalisation des données ;
- Analyse en composantes principales (PCA) ;
- Analyse différentielle avec DESeq2 ;
- Visualisation des résultats (volcano plots, heatmaps, PCA) ;
- Analyses d'enrichissement fonctionnel (Gene Ontology et pathways).

Rapport d'analyses différentiel dispo [ici](https://superlative-banoffee-965645.netlify.app/)

# Outils utilisés

- FastQC / MultiQC
- Cutadapt / Trim Galore
- STAR ou HISAT2
- featureCounts / HTSeq
- DESeq2 (R)


# Organisation du dépôt

```
RNAseq_PRJNA632023/
│
├── raw_data/               # données brutes
├── metadata/               # métadonnées
├── preprocessed/           # données traitées (bam)
├── references/             # génome de références, fichier d'annotation
├── scripts/                # scripts d’analyse différentielle
├── results/                # figures et tableaux
├── Snakefile
└── README.md
```

# Reproductibilité

Ce projet est conçu pour être entièrement reproductible. Toutes les étapes sont documentées et les scripts peuvent être exécutés de manière séquentielle afin de reproduire les résultats obtenus.

# Liens de téléchargement

- Données brutes : https://www.ebi.ac.uk/ena/browser/home (Sample SRR111780536 -> SRR11780615)
- Annotation : https://www.gencodegenes.org/human/ (Basic gene annotation CHR)

***Notes*** 

L'index du génome de référence utilisé pour l'alignement à quant à lui été obtenu via la commande suivante:

```
wget https://genome-idx.s3.amazonaws.com/hisat/grch38_genome.tar.gz
```

# Remarques

Les données brutes sont accessibles publiquement via NCBI SRA (PRJNA632023)
Certaines étapes peuvent nécessiter des ressources computationnelles importantes selon la taille des données. En cas de ressource limité il est possible de lancer les étapes de prétraitement par batch.

# Référence de l'étude

Breen et al. (2020)

RNA-seq analysis of hiPSC-derived neural progenitor cells and neurons carrying SHANK3 deficiency associated with Phelan-McDermid syndrome.
