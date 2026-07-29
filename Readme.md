# Bioinformatics Projects

Ce dépôt regroupe plusieurs projets personnels de bioinformatique développés dans un objectif d'apprentissage, de reproductibilité et de mise en pratique de différentes approches d'analyse de données génomiques et transcriptomiques.

Chaque projet est indépendant et possède son propre pipeline, sa documentation, ses dépendances et son fichier **README** détaillant son fonctionnement.

---

# Objectifs du dépôt

Ce dépôt a pour vocation de :

* centraliser différents projets de bioinformatique ;
* développer des pipelines reproductibles avec **Snakemake** ;
* appliquer des outils couramment utilisés en génomique et transcriptomique ;
* documenter des workflows complets, depuis les données brutes jusqu'aux résultats exploitables.

---

# Projets disponibles

## Variant Annotation Pipeline

Pipeline reproductible d'annotation et de filtrage de variants génomiques issus de trios familiaux à l'aide de **Snakemake**, **VEP**, **LOFTEE** et **Slivar** afin d'identifier des variants rares potentiellement *de novo*.

➡️ Voir le README du projet : `variant_annotation/README.md`

---

## RNA-seq Analysis Pipeline

Pipeline d'analyse transcriptomique RNA-seq permettant de traiter des données publiques depuis les lectures brutes jusqu'à l'analyse d'expression différentielle et l'interprétation biologique.

➡️ Voir le README du projet : `RNAseq_PRJNA632023/README.md`

---

# Organisation générale du dépôt

```text
Bioinformatics_Projects/
│
├── variant_annotation/      # Annotation et filtrage de variants
│   ├── README.md
│   └── ...
│
├── RNAseq_PRJNA632023/       # Pipeline d'analyse RNA-seq
│   ├── README.md
│   └── ...
│
└── README.md                # Présentation générale du dépôt
```

Chaque dossier correspond à un projet autonome comprenant généralement :

* un fichier **README** décrivant le projet ;
* un workflow **Snakemake** ;
* les scripts d'analyse ;
* les fichiers de configuration ;
* les environnements Conda nécessaires à la reproductibilité ;
* une organisation des données et des résultats propre au projet.

---


# Reproductibilité

Chaque projet est conçu pour être reproductible grâce à :

* des workflows automatisés avec **Snakemake** ;
* la gestion des dépendances via **Conda** ;
* une documentation détaillée des différentes étapes d'analyse.

Les instructions d'installation et d'exécution sont disponibles dans le README de chaque projet.

---

# Évolutions du dépôt

Ce dépôt est amené à s'enrichir progressivement de nouveaux projets couvrant différentes thématiques de bioinformatique, telles que l'analyse de variants, la transcriptomique, le machine learning appliqué aux données biologiques ou encore l'analyse d'images.
