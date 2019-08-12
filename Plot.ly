import numpy as np
import pandas as pd
import sys
import math
from collections import defaultdict
import seaborn as sns
import matplotlib.pyplot as plt
%matplotlib inline

def load_data(filename,var):
        df=pd.read_excel(filename)
        data=df[var]
        return df,data
df=pd.read_csv('voting_data_eng.csv')

#EDA
df.head()
df.describe().transpose
df.isnull().sum()
df2=df.groupby(by=['region_name'])['Putin Vladimir Vladimirovich'].mean()
mask=df2>500
df2[mask]

#MATPLOTLIB
df[['Zhirinovskiy Vladimir Volfovich','Grudinin Pavel Nikolaevich']].plot.box(by=None)
df['Putin Vladimir Vladimirovich'].plot.box(by=None)
mask1=df['Putin Vladimir Vladimirovich']<1750
df[mask1]['Putin Vladimir Vladimirovich'].plot.box(by=None)

fig=plt.figure()
ax=plt.axes()
plt.hist(x=df['Putin Vladimir Vladimirovich'],bins=100,data=df,label='Histogram of total votes for Vladimir Putin')
ax.legend(loc=0)

#SEABORN
sns.countplot(x=df[mask1]['Putin Vladimir Vladimirovich'],data=df)

#Create a new dataframe in order to use the columns of participants from the elections and only the first 500 rowes
df3=df.loc[0:500,'ps_id':'Suraikin Maksim Aleksandrovich']

#Plot.ly
#standart plotly imports
import plotly.plotly as py
import plotly.graph_objs as go
from plotly.offline import iplot,init_notebook_mode

import cufflinks
cufflinks.go_offline(connected=True)
init_notebook_mode(connected=True)


df3['Grudinin Pavel Nikolaevich'].iplot(kind='hist',xTitle='Grudinin Pavel Nikolaevich ',
yTitle='count votes',title='Votes Distribution of Grudinin Pavel Nikolaevich')

df3['Putin Vladimir Vladimirovich'].iplot(kind='hist',xTitle='Putin Vladimir Vladimirovich ',yTitle='count votes',
                                          title='Votes Distribution of Putin Vladimir Vladimirovich',colors='blue')
                                          
df3[['Baburin Sergei Nikolaevich','Grudinin Pavel Nikolaevich',
     'Zhirinovskiy Vladimir Volfovich','Putin Vladimir Vladimirovich']].iplot(kind='hist',histnorm='percent',barmode='overlay',
                                                                              xTitle='Votes',yTitle='(%) of candidates',title='Votes Distribution')

df3[['Baburin Sergei Nikolaevich','Grudinin Pavel Nikolaevich',
     'Zhirinovskiy Vladimir Volfovich','Putin Vladimir Vladimirovich']].iplot(kind='box',yTitle='Votes',title='Boxplots')
     

df3[['Baburin Sergei Nikolaevich','Grudinin Pavel Nikolaevich',
     'Zhirinovskiy Vladimir Volfovich','Putin Vladimir Vladimirovich']].iplot(kind='scatter',yTitle='Votes',title='Boxplots')
     


#First_Digit_of votes data
data=df['Putin Vladimir Vladimirovich']
def count_first_digit(data_str):#TAKE AS AN ARGUMENT A STR-COLUMN NAME
    mask=df[data_str]>1.
    data=list(df[mask][data_str])
    for i in range(len(data)):
        while data[i]>=10:
            data[i]=data[i]/10
    first_digits=[int(x) for x in sorted(data)]
    unique=(set(first_digits))#a list with unique values of first_digit list
    data_count=[]
    for i in unique:
        count=first_digits.count(i)
        data_count.append(count)
    total_count=sum(data_count)
    data_percentage=[(i/total_count)*100 for i in data_count]
    return  total_count,data_count, data_percentage


total_count,data_count, data_percentage=count_first_digit('Putin Vladimir Vladimirovich')
total_count,data_count, data_percentage

# Benford's Law percentages for leading digits 1-9

BENFORD = [30.1, 17.6, 12.5, 9.7, 7.9, 6.7, 5.8, 5.1, 4.6]

def get_expected_counts(total_count):

    """Return list of expected Benford's Law counts for total sample count."""

    return [round(p * total_count / 100) for p in BENFORD]
expected_counts=get_expected_counts(total_count)
expected_counts

def chi_square_test(data_count,expected_counts):

    """Return boolean on chi-square test (8 degrees of freedom & P-val=0.05)."""

    chi_square_stat = 0  # chi square test statistic

    for data, expected in zip(data_count,expected_counts):

        chi_square = math.pow(data - expected, 2)

        chi_square_stat += chi_square / expected

    print("\nChi-squared Test Statistic = {:.3f}".format(chi_square_stat))

    print("Critical value at a P-value of 0.05 is 15.51.")    

    return chi_square_stat < 15.51
chi_square_test(data_count,expected_counts)

#ouput:Chi-squared Test Statistic = 9570.310
#Critical value at a P-value of 0.05 is 15.51.
#Out[8]: False


def bar_chart(data_pct):

    """Make bar chart of observed vs expected 1st digit frequency in percent."""

    fig, ax = plt.subplots()



    index = [i + 1 for i in range(len(data_pct))]  # 1st digits for x-axis
# text for labels, title and ticks

    fig.canvas.set_window_title('Percentage First Digits')

    ax.set_title('Data vs. Benford Values', fontsize=15)

    ax.set_ylabel('Frequency (%)', fontsize=16)

    ax.set_xticks(index)

    ax.set_xticklabels(index, fontsize=14)



    # build bars    

    rects = ax.bar(index, data_pct, width=0.95, color='black', label='Data')



    # attach a text label above each bar displaying its height

    for rect in rects:

        height = rect.get_height()

        ax.text(rect.get_x() + rect.get_width()/2, height,

                '{:0.1f}'.format(height), ha='center', va='bottom', 

                fontsize=13)



    # plot Benford values as red dots

    ax.scatter(index, BENFORD, s=150, c='red', zorder=2, label='Benford')



    # Hide the right and top spines & add legend

    ax.spines['right'].set_visible(False)

    ax.spines['top'].set_visible(False)

    ax.legend(prop={'size':15}, frameon=False)

    

    plt.show()
    
    
    def main(data_list):
    total_count,data_count, data_percentage= count_first_digit(data_list)

    expected_counts = get_expected_counts(total_count)

    print("\nobserved counts = {}".format(data_count))

    print("expected counts = {}".format(expected_counts), "\n")


    print("First Digit Probabilities:")

    for i in range(1, 10):

        print("{}: observed: {:.3f}  expected: {:.3f}".

              format(i, data_percentage[i - 1] / 100, BENFORD[i - 1] / 100))



    if chi_square_test(data_count, expected_counts):

        print("Observed distribution matches expected distribution.")

    else:

        print("Observed distribution does not match expected.", file=sys.stderr)       



    bar_chart(data_percentage)  
    
    
    
    
    
    

