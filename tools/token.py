



word_list = []
gen = "gen_clex.txt"
tab = "gen_ytab.txt"
file = open(gen, 'w')
file = open(tab, 'w')
with open('wordlist.txt') as f:
    word_list = f.read().splitlines()
		
n = 345
for i in word_list:
	print("\"", i, "\"\t\t{ tokenize(", i.upper(), ");\t return ", i.upper(), "; }",sep="", file = open(gen, 'a'))
	print("#define", i.upper(), n,sep=" ", file = open(tab, 'a'))
	n += 1
	

