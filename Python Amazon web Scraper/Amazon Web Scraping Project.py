
# importing Libraries

from bs4 import BeautifulSoup
import requests
import smtplib
import time
import datetime


# connect to website to pull in data
URL ="https://www.amazon.in/Good-Hope-Framed-Poster-Office/dp/B083KMTR2H/ref=sr_1_48?crid=33HVN4GBX4RQS&keywords=funny&qid=1678123051&sprefix=funny%2Caps%2C222&sr=8-48" 

headers ={"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36",} 

page =requests.get(URL,headers=headers)

Soup1 =BeautifulSoup(page.content,"html.parser")
Soup2 =BeautifulSoup(Soup1.prettify(),"html.parser")

# extracing the contents from soup
title =Soup2.find(id='productTitle').get_text()
price =Soup2.find(id='corePriceDisplay_desktop_feature_div' ).get_text()


# cleaning the data
title =title.strip() 
Cost=price.split()
price =Cost[1].strip()[1:]

#print(title)
#print(price)


# creating a time stamp for output to track
today =datetime.date.today()


# creating a csv and giving permission to write data
# run only once when creating 

import csv

header =['Title','Price in Rupees','Date']
data =[title,price,today]


"""
    with open('AmazonWebScaperDataSet.csv','w', newline='',encoding ='UTF8')as f:
    writer =csv.writer(f)
    writer.writerow(header)
    writer.writerow(data)
""" 
    
# importing pandas to read csv

import pandas as pd

dataframe =pd.read_csv(r'C:\Users\subha\AmazonWebScaperDataSet.csv')
print(dataframe)


# appending the data to the csv
import csv
data =[title,price,today]
with open('AmazonWebScaperDataSet.csv','a+', newline='',encoding ='UTF8')as f:
    writer =csv.writer(f)
    writer.writerow(data)


# combining the above code into single function

def Check_price():
    URL ="https://www.amazon.in/Good-Hope-Framed-Poster-Office/dp/B083KMTR2H/ref=sr_1_48?crid=33HVN4GBX4RQS&keywords=funny&qid=1678123051&sprefix=funny%2Caps%2C222&sr=8-48" 

    headers ={"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Safari/537.36",} 

    page =requests.get(URL,headers=headers)

    Soup1 =BeautifulSoup(page.content,"html.parser")
    Soup2 =BeautifulSoup(Soup1.prettify(),"html.parser")

    title =Soup2.find(id='productTitle').get_text()
    price =Soup2.find(id='corePriceDisplay_desktop_feature_div' ).get_text()


    title =title.strip() 
    Cost=price.split()
    price =Cost[1].strip()[1:]

    today =datetime.date.today()
    import csv

    header =['Title','Price in Rupees','Date']
    data =[title,price,today]

    with open('AmazonWebScaperDataSet.csv','a+', newline='',encoding ='UTF8')as f:
        writer =csv.writer(f)
        writer.writerow(data)
    
    # sending email for your desired price range
    if(int(price)<250):
        send_mail('your@gmail.com','2fa password','reciever@gmail.com')
        

# checks price after a set time intervals (in seconds)

while(True):
    Check_price()
    time.sleep(10)



# Reading the data from csv

dataframe =pd.read_csv(r'C:\Users\subha\AmazonWebScaperDataSet.csv')
print(dataframe)

# Creating Email and Sending it through smtplib.

import os
from email.message import EmailMessage
import ssl
import smtplib

def send_mail(yourMail,password,recieverMail):
    try:
        
        # Setting up the email subject and body
        subject ="Check this out !. The frame is under 250!"
        body ="The panda frame you wanted is now under 250. Don't miss this chance. Here is the link: https://www.amazon.in/Good-Hope-Framed-Poster-Office/dp/B083KMTR2H/ref=sr_1_48?crid=33HVN4GBX4RQS&keywords=funny&qid=1678123051&sprefix=funny%2Caps%2C222&sr=8-48"

        # Creating an EmailMessage object to hold the email's details
        em =EmailMessage()
        em['From'] =yourMail
        em['To'] =recieverMail
        em['Subject'] =subject
        em.set_content(body)

        # Setting up the SSL context for the SMTP server
        context =ssl.create_default_context()

        # Creating an SMTP server object using Gmail's SMTP server and SSL, and logging in to the email account
        server =smtplib.SMTP_SSL('smtp.gmail.com', 465)
        server.ehlo()
        server.login(yourMail,password)
        
        # Sending the email
        server.sendmail(yourMail,recieverMail,em.as_string())
    except Exception as e:
        print(f"An error occurred: {e}")
    finally:
        # Closing the connection to the SMTP server
        server.quit()

 


