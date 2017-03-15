from utils import *
import matplotlib.pyplot as plt
import numpy as np
from plots_lib import *

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
def boxplot(path_to_file_list, output_file_name, x_axis_tick_labels,  x_label="LSTM Size", graph_title="Accuracy boxplot", limit=-1):
    accuracy_lists = []
    for path_to_file in path_to_file_list:
        accuracy_list = get_accuracy_list(path_to_file, limit)
        accuracy_lists.append(accuracy_list)
        print ("=====================================================")
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

"""
    Parallel coordinate plot
"""
def parallel_cordinates(path_to_file_list, output_file_name, x_axis_tick_labels, x_label, graph_title):
    accuracy_lists = []
    for path_to_file in path_to_file_list:
        accuracy_list = get_accuracy_list(path_to_file)
        accuracy_lists.append(accuracy_list)

    accuracy_by_test = []
    test_id_count = 0
    for test_id in range(0,5):
        test_id_results  = []
        for accuracy_list in accuracy_lists:
            test_id_results.append(accuracy_list[test_id_count])

        print ('test id = ' + str(round(test_id_count,2)))
        print (test_id_results)
        accuracy_by_test.append(test_id_results)
        test_id_count += 1

    colors = ['r','b','g','c','m','y','k','w'] * 30
    parallel_coordinates(accuracy_by_test, style=colors).show()


def runtime_plot(times, files_list_threshold, output_file_name, x_axis_tick_labels, x_label, graph_title):

    accuracy = []
    for path_to_file in files_list_threshold:
        accuracy_list = get_accuracy_list(path_to_file)
        accuracy.append(np.mean(accuracy_list))

    fig, ax = plt.subplots()

    # time plot
    plt.plot(times, 'r')
    plt.plot(times, 'ro')
    plt.title(graph_title)
    plt.xlabel(x_label)
    plt.ylabel("Run time (seconds)", color='r')
    plt.tick_params('y',colors='r')
    plt.xticks(range(0,len(x_axis_tick_labels)))
    ax2 = ax.twinx()
    ax2.plot(accuracy, 'b')
    ax2.plot(accuracy, 'bo')
    ax2.set_ylabel("Accuracy", color='b')
    ax2.tick_params('y',colors='b')

    ax.set_xticklabels(x_axis_tick_labels)
    plt.savefig(output_file_name)


###############################
# ONE LAYER - DIFFERENT SIZE - OLD
###############################
#files_list = ['accuracy/visualization/sherlock_holmes_1_128_tested_with_harry_potter_new_engine.csv', 'accuracy/visualization/sherlock_holmes_1_256_tested_with_harry_potter_new_engine.csv', 'accuracy/visualization/sherlock_holmes_1_512_tested_with_harry_potter_new_engine.csv']

#x_axis_tick_labels = ['128', '256', '512']

###############################
# ONE ITERATION - DIFFERENT SIZE
###############################
files_list = \
['accuracy/visualization/report-data/varying-size-iter-100000/sherlock_holmes_1_128.csv',
'accuracy/visualization/report-data/varying-size-iter-100000/sherlock_holmes_1_256.csv', 'accuracy/visualization/report-data/varying-size-iter-100000/sherlock_holmes_1_512.csv',
'accuracy/visualization/report-data/varying-size-iter-100000/sherlock_holmes_2_128.csv',
'accuracy/visualization/report-data/varying-size-iter-100000/sherlock_holmes_2_256.csv', 'accuracy/visualization/report-data/varying-size-iter-100000/sherlock_holmes_2_512.csv',
'accuracy/visualization/report-data/varying-size-iter-100000/sherlock_holmes_3_128.csv',
'accuracy/visualization/report-data/varying-size-iter-100000/sherlock_holmes_3_256.csv',
'accuracy/visualization/report-data/varying-size-iter-100000/sherlock_holmes_3_512.csv'
]

files_list_tails = \
['sherlock_holmes_1_128.csv','sherlock_holmes_1_256.csv','sherlock_holmes_1_512.csv',
'sherlock_holmes_2_128.csv','sherlock_holmes_2_256.csv','sherlock_holmes_2_512.csv',
'sherlock_holmes_3_128.csv','sherlock_holmes_3_256.csv','sherlock_holmes_3_512.csv'
]

files_list_devil_foot = ['accuracy/visualization/report-data/varying-size-iter-100000-devil-foot/' + file_tail for file_tail in files_list_tails]

x_axis_tick_labels = ['1-128', '1-256', '1-512', '2-128', '2-256', '2-512', '3-128', '3-256', '3-512']
# for i in range(1,10):
#     boxplot(files_list, 'accuracy/visualization/accuracy_vs_size_sherlock_holmes_devil_foot' + str(i), x_axis_tick_labels, 'Number of layer - Layer size', 'Accuracy vs. Size', 40)

# boxplot(files_list_devil_foot, 'accuracy/visualization/accuracy_vs_size_sherlock_holmes_devil_foot', x_axis_tick_labels, 'Number of layers - Layer size', 'Accuracy vs. Size')

# boxplot(files_list, 'accuracy/visualization/accuracy_vs_size_sherlock_holmes', x_axis_tick_labels, 'Number of layers - Layer size', 'Accuracy vs. Size')


#############################
# CHANGING THRESHOLD PLOT
#############################

threshold_tails_1 = [0.01,0.02,0.03,0.04,0.05,0.06,0.07,0.08,0.09, 0.1]
threshold_runtime_1 = [4640, 3646, 3069, 2612, 2272, 2015, 1826, 1666, 1544, 1427]
threshold_runtime_2 = [1427, 989, 876, 839, 831, 453, 458, 484, 433, 442]

# thresholds_accuracy_1 = [0.79, 0.77, 0.75, 0.74, 0.73, 0.72, 0.70, 0.69, 0.68, 0.67]

threshold_tails_2 = [0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1]

files_list_threshold = ['accuracy/visualization/report-data/changing-threshold/thresholds_'+str(tail)+'_.csv' for tail in threshold_tails_2]

x_axis_tick_labels_threshold = [str(tail) for tail in threshold_tails_2]

# runtime_plot(threshold_runtime_2, files_list_threshold, 'accuracy/visualization/runtime_vs_threshold_3_128_sherlock_on_harrypotter_large', x_axis_tick_labels_threshold, 'Cut-off probability', 'Run time vs. Cut-off probability')

# boxplot(files_list_threshold, 'accuracy/visualization/accuracy_vs_threshold_3_128_sherlock_on_harry_large', x_axis_tick_labels_threshold, 'Cut off probability', 'Cut off probability vs. Accuracy')


#############################
# CHANGING LOOKFORWAR LEN
#############################

lookforward_tails = [0,1,2,3,4,5,6,7,8,9,10,100]
lookforward_runtime = [1475, 1746, 2525, 2751, 3007, 3800, 4017, 4710, 4956, 5172, 5800, 9190]

files_list_lookforward = ['accuracy/visualization/report-data/changing-lookforwardlen/lookforward_len_'+str(tail)+'_.csv' for tail in lookforward_tails]

x_axis_tick_labels_lookforward = [str(tail) for tail in lookforward_tails]
x_axis_tick_labels_lookforward[-1] = 'All'
runtime_plot(lookforward_runtime, files_list_lookforward, 'accuracy/visualization/runtime_vs_lookforwardlen_3_128_sherlock_on_harrypotter', x_axis_tick_labels_lookforward, 'Number of symbols to look forward ', 'Run time vs. Number of symbols to look forward ')

# boxplot(files_list_lookforward, 'accuracy/visualization/accuracy_vs_lookforwardlen_3_128_sherlock_on_harry', x_axis_tick_labels_lookforward, 'Number of symbols to look forward', 'Number of symbols to look forward vs. Accuracy')


#############################
# IMPROVEMENT OVER NAIVE ENGINE PLOT
#############################

# files_list_improvement = \
# ['accuracy/visualization/report-data/naive/harrypotter_3_128.csv', 'accuracy/visualization/report-data/varying-size-iter-100000/sherlock_holmes_3_128.csv']
#
# x_axis_tick_labels_improvement = ['Naive', 'With looking forward']
#
# boxplot(files_list_improvement, 'accuracy/visualization/accuracy_naive_improved_harrypotter', x_axis_tick_labels_improvement, 'Approach', 'Improvement over naive approach')

#############################
# 1-128 CHANGING ITERATION
#############################

def plot_changing_iteration_1_128(containing_folder, graph_name):
    files_list = ['accuracy/visualization/report-data/' + containing_folder + '/sherlock_holmes_1_128_ITER_' + str(i*10000) +'.csv' for i in range(1,11)]
    x_axis_tick_labels = [str(i*10000) for i in range(1,11)]
    boxplot(files_list, 'accuracy/visualization/' + graph_name, x_axis_tick_labels, 'Number of training iterations', 'Accuracy vs. Training Iterations')

# plot_changing_iteration_1_128('changing-iteration-1-128', 'accuracy_vs_training_iteration_sherlock_holmes_1_128.png')
