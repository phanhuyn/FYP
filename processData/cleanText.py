# -*- coding: utf-8 -*-

# python script to read a text file, and clean them to set of 'standard unit'

# usage
# python processData/cleanText.py data/sherlock_holmes.txt
import sys

# those are the characters we want to keep
ALPHABET = '\n !"\'(),.0123456789:;?ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'

ALPHABET_MINIMIZE = ' \'!,.:?0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'

VIETNAMESE_ALPHABET_MINIMIZE = '\'",.:;?abcdefghijklmnopqrstuvwxyz àáâãèéêìíðòóôõùúýăđĩũơưạảấầẩẫậắằẳẵặẹẻẽếềểễệỉịọỏốồổỗộớờởỡợụủứừửữựỳỵỷỹ\n'.decode('utf8')

def cleantext(input_file_name, alphabet):

    output_file_name = input_file_name[:-4] + '_cleaned.txt'

    with open(input_file_name) as input_file:
        data = input_file.read().decode('utf8')

        for char in ''.join(set(data)):
            if char not in alphabet:
                data = data.replace(char, ' ')

        # removing multi blank space
        data = ' '.join(data.split())

        with open(output_file_name, "w") as text_file:
            text_file.write(data.encode('utf8'))

def cleantextLower(input_file_name, alphabet):

    output_file_name = input_file_name[:-4] + '_cleaned.txt'

    with open(input_file_name) as input_file:
        data = input_file.read().decode('utf8').lower()

        all_chars = ''.join(set(data))

        for char in all_chars:
            if char not in alphabet:
                data = data.replace(char, ' ')

        # removing multi blank space
        data = ' '.join(data.split())

        data = data.replace(' .', '.')

        with open(output_file_name, "w") as text_file:
            text_file.write(data.encode('utf8'))

def text_stats(input_file_name):

    with open(input_file_name, ) as input_file:
        all_text = input_file.read().decode('utf8')
        print ("Text size: ")
        print len(all_text)
        print ("No. unique symbols")
        all_chars = ''.join(set(all_text)).lower()
        all_chars = ''.join(set(all_chars))
        print (len(all_chars))
        print (''.join(sorted(all_chars)))


# text_stats("data/Vietnamese_GoneWithTheWind.txt")
# cleantextLower("data/Vietnamese_GoneWithTheWind.txt", VIETNAMESE_ALPHABET_MINIMIZE)
# text_stats("accuracy/rawTestFiles/harrypotter_onefile/harrypotter2.txt")
text_stats("accuracy/rawTestFiles/ntu_news_matched.txt")
