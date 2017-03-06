# python script to read a text file, and clean them to set of 'standard unit'

# usage
# python processData/cleanText.py data/sherlock_holmes.txt
import sys

# those are the characters we want to keep
ALPHABET = '\n !"\'(),.0123456789:;?ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'

ALPHABET_MINIMIZE = ' \'!,.:?0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'


def cleantext(input_file_name):

    output_file_name = input_file_name[:-4] + '_cleaned.txt'

    with open(input_file_name) as input_file:
        data = input_file.read()

        for char in data:
            if char not in ALPHABET_MINIMIZE:
                data = data.replace(char, ' ')

        data = ' '.join(data.split())
        
        with open(output_file_name, "w") as text_file:
            text_file.write(data)

if __name__ == "__main__":
    arguments = sys.argv
    text_to_clean = arguments[1]
    cleantext(text_to_clean)
