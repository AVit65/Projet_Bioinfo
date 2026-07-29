Variant Annotation Pipeline – Snakemake Reproducible Workflow

# Présentation du projet

Ce projet vise à mettre en place un pipeline reproductible d’annotation et de filtrage de variants génomiques à partir de fichiers VCF issus de données de trios familiaux.

Les données proviennent de trios humains issus de projets de génomique populationnelle (ex : 1000 Genomes), organisés par chromosomes et par individus.

L’objectif biologique est d’identifier et caractériser des variants rares potentiellement de novo au sein de trios parent-enfant, en combinant :

annotation fonctionnelle des variants (VEP),
prédiction de perte de fonction (LOFTEE),
analyse de transmission familiale (Slivar),
et structuration des données en format exploitable pour analyses downstream.

# Objectifs du pipeline

L’objectif principal de ce projet est de :

- Fusionner et normaliser les fichiers VCF par individu et par cohorte de trios
- Annoter les variants avec Ensembl VEP
- Ajouter des prédictions de perte de fonction avec LOFTEE
- Identifier les variants compatibles avec une transmission de novo via Slivar
- Reformater les résultats en tables exploitables pour analyses statistiques ou bioinformatiques
- Garantir une reproductibilité complète via Snakemake + conda

# Description du pipeline

Le workflow est entièrement automatisé avec Snakemake et se décompose en plusieurs étapes :

## Préparation des données VCF

Les fichiers VCF sont fournis par chromosome pour chaque trio.

Les étapes incluent :

- concaténation des chromosomes pour chaque individu (bcftools concat)
- fusion des trios en un VCF multi-échantillons (bcftools merge)
- indexation des fichiers avec tabix

Exemple d’exécution manuelle

### concaténation des chromosomes pour un individu

```
bcftools concat \
raw_data/VCF/Trio1/NA12878_1463_CEUTrio.chr{1..22}.vcf.gz \
raw_data/VCF/Trio1/NA12878_1463_CEUTrio.chrX.vcf.gz \
-Oz -o results/VCF/trio1.vcf.gz
```

### indexation
```
tabix -p vcf results/VCF/trio1.vcf.gz
```

### fusion des trios

```
bcftools merge \
results/VCF/trio1.vcf.gz results/VCF/trio2.vcf.gz \
-Oz -o results/VCF/all_trios.vcf.gz
```

## Annotation des variants avec VEP + LOFTEE

Les variants sont annotés à l’aide d’Ensembl VEP (v115).

Les annotations incluent :

- conséquences fonctionnelles des variants
- impact protéique
- annotations populationnelles (gnomAD, 1000 Genomes)
- prédictions deleteriousness

LOFTEE est utilisé pour améliorer la prédiction des variants perte de fonction (LoF) en filtrant les faux positifs.

Exemple d’exécution VEP

```
vep \
-i results/VCF/all_trios.vcf.gz \
-o results/VEP/variants.vep.vcf.gz \
--vcf \
--cache \
--offline \
--assembly GRCh38 \
--everything \
--fork 4 \
--plugin LoF,loftee_path:/path/to/loftee,\
human_ancestor_fa:/path/human_ancestor.fa.gz,\
gerp_bigwig:/path/gerp.bw
```

## Analyse familiale avec Slivar

Slivar est utilisé pour identifier les variants compatibles avec une transmission de novo dans les trios.

Le fichier PED décrit les relations parent-enfant.

```

slivar expr \
--vcf results/VEP/variants.vep.vcf.gz \
--ped raw_data/ped/ped.txt \
--trio "denovo:kid.het && mom.hom_ref && dad.hom_ref" \
--pass-only \
> results/slivar/variants.slivar.vcf
```

## Conversion en table exploitable

Les variants filtrés sont convertis en format tabulaire pour analyses downstream :

extraction des champs VCF avec bcftools query
restructuration des génotypes par individu avec awk
Exemple

```

bcftools query \
-f '%CHROM\t%POS\t%ID\t%REF\t%ALT\t%INFO/CSQ[\t%SAMPLE=%GT]\n' \
results/slivar/variants.slivar.vcf \
> results/temp/variants_samples.txt
awk -f scripts/split_samples.awk \
results/temp/variants_samples.txt \
> results/tables/variants.tab.tsv
```


## Exécution du pipeline Snakemake

L’ensemble du workflow est automatisé via Snakemake.

```

snakemake --cores 4 --use-conda
```



# Outils utilisés

- bcftools
- htslib / tabix
- samtools
- Ensembl VEP (v115)
- LOFTEE plugin
- Slivar
- awk
- Snakemake
- Conda

# Organisation du dépôt

```
variant_annotation/
│
├── raw_data/              # fichiers VCF par trio et chromosomes
│   ├── VCF/
│   └── ped/
│
├── results/
│   ├── VCF/               # VCF concaténés et fusionnés
│   ├── VEP/               # VEP annotations
│   ├── slivar/            # variants filtrés de novo
│   ├── tables/            # tableaux finaux
│   └── temp/              # fichiers intermédiaires
│
├── scripts/               # scripts awk
├── envs/                  # environnements conda
├── Snakefile              # pipeline Snakemake
├── config.yaml            # configuration globale
└── README.md
```

# Reproductibilité

Ce projet est entièrement reproductible grâce à :

- Snakemake pour l’orchestration des analyses
- Conda pour la gestion des environnements
- fichiers de configuration centralisés (config.yaml)

# Remarques importantes
LOFTEE nécessite des fichiers externes :
- human ancestor fasta
- GERP conservation scores
- Les performances peuvent varier selon le nombre de trios et la taille des VCF
- VEP est une étape coûteuse en temps de calcul
- Slivar requiert un fichier PED correctement formaté

# Référence
- Slivar: Pedersen et al., 2020
- Ensembl VEP: McLaren et al., Genome Biology
- LOFTEE: Karczewski et al., bioRxiv
- 1000 Genomes Project Consortium

# Remarques

Ce pipeline est conçu pour être :

- scalable (multi-trios)
- reproductible
- modulaire (chaque étape peut être exécutée indépendamment)
- compatible analyse clinique ou recherche
