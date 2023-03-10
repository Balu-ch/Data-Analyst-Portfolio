Amazon Product Scraper
This is a Python project that allows you to scrape product data from Amazon's website and send an email notification if the product you want reaches a certain price. This can be very useful during sales, when prices drop and you want to take advantage of the discount.

Installation
Clone the repository to your local machine.
Install the required dependencies using pip: pip install -r requirements.txt

Usage
Run python Amazon Web Scraping Project.py to start the scraper or You can also Run Amazon Web Scraping Project.ipynb in jupyter for better result .
Enter the URL of the product you want to monitor and the target price.
Optionally, you can set a timer to run the scraper at regular intervals.
If the product reaches the target price, you will receive an email notification with a link to the product.
Configuration
To use the email notification feature, you need to configure your email provider settings in the config.py file. You can use Gmail or any other provider that supports SMTP.

Output
The product data is stored in a CSV file named AmazonWebScaperDataSet.csv (it usually stores in user files) , which you can read with Pandas or any other CSV reader.
The below images SS1.jpeg, SS2.jpeg are the screenshots of the mails recieved. 