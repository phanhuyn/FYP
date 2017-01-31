# python script to read a text file, break them into sentences and write them into multiple text files
# Using ntlk tokenizer http://www.nltk.org/api/nltk.tokenize.html

import sys, os
import nltk.data

"""
    path_to_file: path to the text file which we want to break
    path_to_test_group: path to the location which we want to store the smaller test cases
    min_len: minimum length of a test case
"""
def breakTextFile(path_to_file, path_to_test_group, min_len=150):

    # creating the directory
    if not os.path.exists(path_to_test_group):
        os.makedirs(path_to_test_group)

    with open(path_to_file, 'r') as myfile:
        data=myfile.read()

    sent_detector = nltk.data.load('tokenizers/punkt/english.pickle')
    current_sentence = ''
    test_count = 1
    for sentence in sent_detector.tokenize(data.strip()):
        current_sentence = current_sentence + ' ' + sentence
        if len(current_sentence) > min_len:
            # write to text file
            output_path = path_to_test_group + '/testcaseno' + str (test_count) + '.txt'
            with open(output_path, "w") as text_file:
                text_file.write(current_sentence[1:])
            test_count = test_count + 1
            current_sentence = ''

if __name__ == "__main__":
    arguments = sys.argv
    path_to_file = arguments[1]
    path_to_test_group= arguments[2]
    if (len(arguments) > 3):
        min_len = int (arguments[3])
        breakTextFile(path_to_file, path_to_test_group, min_len)
    else:
        breakTextFile(path_to_file, path_to_test_group)
