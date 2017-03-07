import csv, sys
import numpy as np

"""
    Read a csv file of (correct, incorrect) and return a list of accuracy
"""
def get_accuracy_list(path_to_file):
    with open(path_to_file) as csv_file:

        reader = csv.reader(csv_file)

        accuracy_list = []
        header = True
        for row in reader:
            if not header:
                correct_gap = float(row[1])
                incorrect_gap = float(row[2])
                accuracy = correct_gap/(incorrect_gap+correct_gap)
                accuracy_list.append(accuracy)
            header = False
        return accuracy_list


"""
 print mean, max, min & median of a test
"""
def print_stats(accuracy_list):
    print ("Number of test runs: " + str(len(accuracy_list)))
    print ("Average accuracy: " + str(np.mean(accuracy_list)))
    print ("Median accuracy: " + str(np.median(accuracy_list)))
    # print ("Max accuracy: " + str(statistics.mean(accuracy_list)))
    # print ("Min accuracy: " + str(statistics.mean(accuracy_list)))

if __name__ == "__main__":
    arguments = sys.argv
    path_to_file = arguments[1]
    get_accuracy_list(path_to_file)
