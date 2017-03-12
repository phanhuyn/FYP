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



###############################
# ONE LAYER - DIFFERENT SIZE - OLD
###############################
#files_list = ['accuracy/visualization/sherlock_holmes_1_128_tested_with_harry_potter_new_engine.csv', 'accuracy/visualization/sherlock_holmes_1_256_tested_with_harry_potter_new_engine.csv', 'accuracy/visualization/sherlock_holmes_1_512_tested_with_harry_potter_new_engine.csv']

#x_axis_tick_labels = ['128', '256', '512']

###############################
# ONE LAYER - DIFFERENT SIZE
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

boxplot(files_list_devil_foot, 'accuracy/visualization/accuracy_vs_size_sherlock_holmes_devil_foot', x_axis_tick_labels, 'Number of layer - Layer size', 'Accuracy vs. Size')

#############################
# 2-512 CHANGING ITERATION
#############################

# 2-512 - DIFFERENT ITERATION IN TRAINING
# files_list = ['accuracy/visualization/report-data/changing-iteration-2-512/sherlock_holmes_2_512_tested_with_harry_potter_new_engine_ITER_10000.csv',\
#  'accuracy/visualization/report-data/changing-iteration-2-512/sherlock_holmes_2_512_tested_with_harry_potter_new_engine_ITER_20000.csv',\
#  'accuracy/visualization/report-data/changing-iteration-2-512/sherlock_holmes_2_512_tested_with_harry_potter_new_engine_ITER_30000.csv',\
#  'accuracy/visualization/report-data/changing-iteration-2-512/sherlock_holmes_2_512_tested_with_harry_potter_new_engine_ITER_40000.csv',\
#  'accuracy/visualization/report-data/changing-iteration-2-512/sherlock_holmes_2_512_tested_with_harry_potter_new_engine_ITER_50000.csv',\
#  'accuracy/visualization/report-data/changing-iteration-2-512/sherlock_holmes_2_512_tested_with_harry_potter_new_engine_ITER_60000.csv',\
#  'accuracy/visualization/report-data/changing-iteration-2-512/sherlock_holmes_2_512_tested_with_harry_potter_new_engine_ITER_70000.csv',\
#  'accuracy/visualization/report-data/changing-iteration-2-512/sherlock_holmes_2_512_tested_with_harry_potter_new_engine_ITER_80000.csv',\
# 'accuracy/visualization/report-data/changing-iteration-2-512/sherlock_holmes_2_512_tested_with_harry_potter_new_engine_ITER_90000.csv',\
#  ]
# x_axis_tick_labels = ['10000', '20000', '30000', '40000', '50000', '60000', '70000', '80000', '90000']
# boxplot(files_list, 'accuracy/visualization/accuracy_vs_training_iteration_sherlock_holmes.png', x_axis_tick_labels, 'Number of training iterations', 'Accuracy vs. Training Iterations')

#############################
# 1-128 CHANGING ITERATION
#############################

def plot_changing_iteration_1_128(containing_folder, graph_name):
    files_list = ['accuracy/visualization/report-data/' + containing_folder + '/sherlock_holmes_1_128_ITER_' + str(i*10000) +'.csv' for i in range(1,11)]
    print (files_list)
    x_axis_tick_labels = ['10000', '20000', '30000', '40000', '50000', '60000', '70000', '80000', '90000','100000']
    boxplot(files_list, 'accuracy/visualization/' + graph_name, x_axis_tick_labels, 'Number of training iterations', 'Accuracy vs. Training Iterations')

#plot_changing_iteration_1_128('changing-iteration-1-128-double-check', 'accuracy_vs_training_iteration_sherlock_holmes_1_128_double_check.png')
