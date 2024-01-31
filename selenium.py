# Install Selenium on your server
pip install selenium

# Install ChromeDriver on your server
wget https://chromedriver.storage.googleapis.com/92.0.4515.107/chromedriver_linux64.zip
unzip chromedriver_linux64.zip
sudo mv chromedriver /usr/local/bin/

# Create a test script that defines your test cases
cat > test.py << EOF
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import unittest

class TestYourApp(unittest.TestCase):

  def setUp(self):
    self.driver = webdriver.Chrome()
    self.driver.get("http://localhost:3000")

  def test_title(self):
    self.assertEqual(self.driver.title, "Your App")

  def test_search(self):
    search_box = self.driver.find_element(By.NAME, "q")
    search_box.send_keys("hello")
    search_box.send_keys(Keys.RETURN)
    results = WebDriverWait(self.driver, 10).until(EC.presence_of_element_located((By.ID, "results")))
    self.assertIn("hello", results.text)

  def tearDown(self):
    self.driver.quit()

if __name__ == "__main__":
  unittest.main()
EOF

# Run your test script on your server
python test.py
