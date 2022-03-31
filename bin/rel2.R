import sys
relfile = sys.argv[1]
excess_rel = sys.argv[2]
ids_to_keep = sys.argv[3]
outFile = sys.argv[4]


import pandas as pd
rel = pd.read_csv(relfile, sep=" ")
txtfile=open(excess_rel)
excess_rel=[]
for line in (txtfile):
     excess_rel.append(int(line.rstrip()))
txtfile=open(ids_to_keep)
ids=[]
for line in (txtfile):
    ids.append(int(line.rstrip()))

rel_excess_removed = rel[~rel.ID1.isin(excess_rel)]

extract = []
for i, j in zip(rel_excess_removed.ID1, rel_excess_removed.ID2):
    if (i not in extract and j not in extract):
            if i in ids:
                extract.append(j)
            else:
                extract.append(i)


with open(outFile, 'w') as file: #extract_4.txt
    for item in extract:
        file.write("{}\n".format(item))
