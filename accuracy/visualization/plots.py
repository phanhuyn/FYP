from utils import *
import matplotlib.pyplot as plt
import numpy as np

"""
    Draw histogram with the accuracy report in path_to_file, save the result to output_file_name
"""
def histogram(path_to_file, output_file_name, graph_title="Accuracy histogram"):
    accuracy_list = get_accuracy_list(path_to_file)
    plt.hist(accuracy_list)
    plt.title(graph_title)
    plt.xlabel("Accuracy")
    plt.ylabel("Frequency")
    plt.savefig(output_file_name)


"""
    Draw boxplot with the accuracy report in path_to_file, save the result to output_file_name
"""
def boxplot(path_to_file, output_file_name, graph_title="Accuracy boxplot"):
    accuracy_list = get_accuracy_list(path_to_file)
    plt.hist(accuracy_list)
    plt.title(graph_title)
    plt.xlabel("Accuracy")
    plt.ylabel("Frequency")
    plt.savefig(output_file_name)


# python accuracy/visualization/plots.py accuracy/visualization/sherlock_holmes_1_128_tested_with_harry_potter_new_engine.csv accuracy/visualization/sherlock_holmes_1_128_tested_with_harry_potter_new_engine.png
if __name__ == "__main__":
    arguments = sys.argv
    path_to_file = arguments[1]
    output_file_name = arguments[2]
    histogram(path_to_file, output_file_name)
