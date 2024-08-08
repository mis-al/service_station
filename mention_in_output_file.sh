grep ': 654903' outputALL5.txt  | grep '\-CFF\-' > 654903_CFF.txt
grep ': 654903' outputALL5.txt  | grep '\-CFF\-' | cut -d',' -f 2 | cut -d' ' -f 4 | cut -d'.' -f1 > 654903_CFF_versions.txt
grep ': 654903' outputALL5.txt  | grep '\-SMR\-' > 654903_SMR.txt
grep ': 654903' outputALL5.txt  | grep '\-SMR\-' | cut -d',' -f 2 | cut -d' ' -f 4 | cut -d'.' -f1 > 654903_SMR_versions.txt