import csv, sys
import numpy as np

"""
    Read a csv file of (correct, incorrect) and return a list of accuracy
"""
def get_accuracy_list(path_to_file, limit=-1):
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
        if (limit != -1):
            import random
            return random.sample(accuracy_list, limit)
        return accuracy_list


"""
 print mean, max, min & median of a test
"""
def print_stats(accuracy_list):
    print ("Number of test runs: " + str(len(accuracy_list)))
    print ("Average accuracy: " + str(np.mean(accuracy_list)))
    print ("Median accuracy: " + str(np.median(accuracy_list)))
    print ("25 percentile: " + str(np.percentile(accuracy_list, 25)))
    print ("75 percentile: " + str(np.percentile(accuracy_list, 75)))

    # print ("Max accuracy: " + str(statistics.mean(accuracy_list)))
    # print ("Min accuracy: " + str(statistics.mean(accuracy_list)))

#print_stats(get_accuracy_list('accuracy/visualization/report-data/naive/harrypotter_1_128.csv'))
