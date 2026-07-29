BEGIN {
    FS=OFS="\t"

    # Ecriture du nom des colonnes
    print "CHROM", "POS", "ID", "REF", "ALT", "CSQ", "SAMPLE", "GT"
}

{
    # Identification des différentes colonnes
    chrom = $1
    pos   = $2
    id    = $3
    ref   = $4
    alt   = $5
    denovo = $6
    csq   = $7

    # Création du nouveau champs CSQ
    new_csq = ""

    # Split du champ CSQ
    n = split(csq, annotations, ",")

    # Reconstruction du champ CSQ
    for (j = 1; j <= n; j++) {

        split(annotations[j], a, "|")

        # Réduction du champ CSQ en conservant le format VEP
        reduced = a[2] "|" \
                  a[3] "|" \
                  a[4] "|" \
                  a[5] "|" \
                  a[7] "|" \
                  a[8] "|" \
                  a[11] "|" \
                  a[12] "|" \
                  a[25] "|" \
                  a[38] "|" \
                  a[39] "|" \
                  a[90] "|" \
                  a[91] "|" \
                  a[92] "|" \
                  a[93]

        if (new_csq == "")
            new_csq = reduced
        else
            new_csq = new_csq "," reduced
    }

    Reconstruction du champ génotype
    for (i = 8; i <= NF; i++) {

        eq = index($i, "=")

        sample = substr($i, 1, eq-1)
        gt   = substr($i, eq+1)

        # Filtre sur les cas de novo identifiés par Slivar
        if (name == denovo) {

            print chrom, pos, id, ref, alt, new_csq, sample, gt
        }
    }
}