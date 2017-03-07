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
def boxplot(path_to_file_list, output_file_name, x_axis_tick_labels,  x_label="LSTM Size", graph_title="Accuracy boxplot"):
    accuracy_lists = []
    for path_to_file in path_to_file_list:
        accuracy_list = get_accuracy_list(path_to_file)
        accuracy_lists.append(accuracy_list)
        print ("Statistics of file: " + path_to_file)
        print_stats(accuracy_list)
    fig, ax = plt.subplots()
    plt.boxplot(accuracy_lists)
    plt.title(graph_title)
    plt.xlabel(x_label)
    plt.ylabel("Accuracy")
    ax.set_xticklabels(x_axis_tick_labels)

    # plt.show()
    plt.savefig(output_file_name)

# ONE LAYER - DIFFERENT SIZE

#files_list = ['accuracy/visualization/sherlock_holmes_1_128_tested_with_harry_potter_new_engine.csv', 'accuracy/visualization/sherlock_holmes_1_256_tested_with_harry_potter_new_engine.csv', 'accuracy/visualization/sherlock_holmes_1_512_tested_with_harry_potter_new_engine.csv']

#x_axis_tick_labels = ['128', '256', '512']

# 2-512 - DIFFERENT ITERATION IN TRAINING
files_list = ['accuracy/visualization/changing-iteration/sherlock_holmes_2_512_tested_with_harry_potter_new_engine_ITER_10000.csv', 'accuracy/visualization/changing-iteration/sherlock_holmes_2_512_tested_with_harry_potter_new_engine_ITER_20000.csv','accuracy/visualization/changing-iteration/sherlock_holmes_2_512_tested_with_harry_potter_new_engine_ITER_30000.csv','accuracy/visualization/changing-iteration/sherlock_holmes_2_512_tested_with_harry_potter_new_engine_ITER_40000.csv','accuracy/visualization/changing-iteration/sherlock_holmes_2_512_tested_with_harry_potter_new_engine_ITER_50000.csv','accuracy/visualization/changing-iteration/sherlock_holmes_2_512_tested_with_harry_potter_new_engine_ITER_60000.csv']
x_axis_tick_labels = ['10000', '20000', '30000', '40000', '50000', '60000']
boxplot(files_list, 'accuracy/visualization/accuracy_vs_training_iteration_sherlock_holmes.png', x_axis_tick_labels, 'Number of training iterations', 'Accuracy vs. Training Iterations')
