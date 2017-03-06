import csv, sys

"""
    Read a csv file of (correct, incorrect) and return a list of accuracy
"""
def get_accuracy_list(path_to_file):
    with open(path_to_file) as csv_file:

        reader = csv.reader(csv_file)
        for row in reader:
            print row

if __name__ == "__main__":
    arguments = sys.argv
    path_to_file = arguments[1]
    get_accuracy_list(path_to_file)
