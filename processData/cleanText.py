# -*- coding: utf-8 -*-

# python script to read a text file, and clean them to set of 'standard unit'

# usage
# python processData/cleanText.py data/sherlock_holmes.txt
import sys

# those are the characters we want to keep
ALPHABET_1 = '\n !"\'(),.0123456789:;?ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'

ALPHABET_2 = ' \'!,.:?0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'

ALPHABET_3 = '\n !,.:?ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'

ALPHABET_4 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'

ALPHABET_5 = 'abcdefghijklmnopqrstuvwxyz'

PYTHON_ALPHABET = "\n !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~"

VIETNAMESE_ALPHABET_MINIMIZE = '\'",.:;?abcdefghijklmnopqrstuvwxyz àáâãèéêìíðòóôõùúýăđĩũơưạảấầẩẫậắằẳẵặẹẻẽếềểễệỉịọỏốồổỗộớờởỡợụủứừửữựỳỵỷỹ\n'.decode('utf8')

def cleantext(input_file_name, output_file_name, alphabet):

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

def cleantextPython(input_file_name, alphabet):

    output_file_name = input_file_name[:-4] + '_cleaned.txt'

    with open(input_file_name) as input_file:
        data = input_file.read().decode('utf8')

        for char in ''.join(set(data)):
            if char not in alphabet:
                data = data.replace(char, '')

        with open(output_file_name, "w") as text_file:
            text_file.write(data.encode('utf8'))

def text_stats(input_file_name):

    with open(input_file_name, ) as input_file:
        all_text = input_file.read().decode('utf8')
        print ("Text size: ")
        print len(all_text)
        print ("No. unique symbols")
        all_chars = ''.join(set(all_text))
        # all_chars = ''.join(set(all_chars))
        print (len(all_chars))
        print (''.join(sorted(all_chars)))


# text_stats("data/indonesian_cleaned.txt")
# text_stats("accuracy/rawTestFiles/harrypotter_onefile/harrypotter2.txt")
# text_stats("accuracy/rawTestFiles/ntu_news_matched.txt")
# cleantextPython("data/python_code.txt", PYTHON_ALPHABET)
# text_stats("data/python_code_cleaned.txt")

cleantext("data/sherlock_holmes_cleaned.txt", "data/sherlock_holmes_alpha4.txt", ALPHABET_4)
text_stats("data/sherlock_holmes_alpha4.txt")
#
# cleantext("data/sherlock_holmes_cleaned.txt", "data/sherlock_holmes_alpha5.txt", ALPHABET_5)
# text_stats("data/sherlock_holmes_alpha5.txt")
