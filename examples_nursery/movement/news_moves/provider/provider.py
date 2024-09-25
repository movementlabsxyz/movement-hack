import requests
from bs4 import BeautifulSoup
from subprocess import run, CalledProcessError
import time
import logging

# Logging setup
logging.basicConfig(level=logging.INFO)

# Function to scrape the latest news article from a website
def scrape_latest_article():
    url = 'https://example.com/news'  # Replace with the actual URL of the website
    try:
        response = requests.get(url)
        response.raise_for_status()  # Проверка статуса ответа
        soup = BeautifulSoup(response.content, 'html.parser')

        # Here you need to adjust according to the structure of the website
        article_title = soup.find('h1').get_text(strip=True)
        article_content = soup.find('div', class_='article-body').get_text(strip=True)

        return article_title, article_content
    except requests.exceptions.RequestException as e:
        logging.error(f"Error scraping the news article: {e}")
        return None, None

# Function to call the NewsMoves contract on the Diem blockchain using Move CLI
def call_news_moves_contract(timestamp, title, content, signer_address):
    try:
        command = [
            'move', 'call',
            '--signer', signer_address,
            '--script', 'NewsMoves.mvir',
            'addArticle', f'({timestamp}, "{title}", "{content}")'
        ]
        run(command, check=True)
        logging.info(f"Successfully called the contract with title: {title}")
    except CalledProcessError as e:
        logging.error(f"Error calling the contract: {e}")

# Main program logic
def main():
    while True:
        try:
            # Scrape the latest news article
            article_title, article_content = scrape_latest_article()

            if article_title and article_content:
                # Get the current timestamp
                current_timestamp = int(time.time())

                # Specify the signer's address (replace with the actual signer's address)
                signer_address = "0x0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef"

                # Call the NewsMoves contract on the Diem blockchain
                call_news_moves_contract(current_timestamp, article_title, article_content, signer_address)
            else:
                logging.warning("No article found or scraping failed.")

            # Sleep for the specified interval (e.g., 1 hour)
            time.sleep(3600)

        except KeyboardInterrupt:
            logging.info("Program interrupted by user. Exiting...")
            break

# Run the program
if __name__ == "__main__":
    main()
