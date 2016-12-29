# python script to generate test set

MIN_PREFIX = 5
MAX_PREFIX = 20

MIN_GAP = 1
MAX_GAP = 3

def generateTest(path_to_file, gap_char):
    """Generating a test
    path_to_file: text file to put gap in
    gap_char: the character denoting the gap
    """

    with open(path_to_file) as f:
    	print (f.readlines())

generateTest('accuracy/rawTestFiles/big.txt', 'a')