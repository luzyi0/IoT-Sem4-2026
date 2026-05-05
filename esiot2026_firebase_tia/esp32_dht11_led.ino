// Kode Arduino untuk ESP32 dengan DHT11 dan LED
// Upload kode ini ke ESP32 menggunakan Arduino IDE

#include <WiFi.h>
#include <FirebaseESP32.h>

// Konfigurasi WiFi
#define WIFI_SSID "Sutikno-EXT"
#define WIFI_PASSWORD "131464637"

// Konfigurasi Firebase
#define API_KEY "AIzaSyABHv8mytSUkY6C0eN4iaTQKOH3rZrf2NA"
#define DATABASE_URL "https://iotia-e79cb-default-rtdb.firebaseio.com/"
#define USER_EMAIL "iotia2026ti2b@gmail.com"
#define USER_PASSWORD "12345678"

// Pin definitions
#define DHTPIN 4          // Pin untuk DHT11 (GPIO 4)
#define DHTTYPE DHT11     // Tipe sensor DHT
#define LED_PIN 2         // Pin LED internal ESP32 (GPIO 2)

// Inisialisasi
DHT dht(DHTPIN, DHTTYPE);
FirebaseData firebaseData;
FirebaseAuth auth;
FirebaseConfig config;

void setup() {
  Serial.begin(115200);

  // Setup LED
  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, LOW); // LED mati awal

  // Setup DHT
  dht.begin();

  // Koneksi WiFi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());

  // Konfigurasi Firebase
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  Serial.println("Firebase connected");
}

void loop() {
  // Baca sensor DHT11
  float humidity = dht.readHumidity();
  float temperature = dht.readTemperature();

  // Cek jika pembacaan valid
  if (isnan(humidity) || isnan(temperature)) {
    Serial.println("Failed to read from DHT sensor!");
    return;
  }

  // Kirim data ke Firebase
  if (Firebase.setFloat(firebaseData, "/esiot-db/suhu", temperature)) {
    Serial.println("Temperature sent to Firebase");
  } else {
    Serial.println("Failed to send temperature: " + firebaseData.errorReason());
  }

  if (Firebase.setFloat(firebaseData, "/esiot-db/kelembapan", humidity)) {
    Serial.println("Humidity sent to Firebase");
  } else {
    Serial.println("Failed to send humidity: " + firebaseData.errorReason());
  }

  // Kontrol LED dari Firebase
  if (Firebase.getInt(firebaseData, "/esiot-db/led")) {
    int ledStatus = firebaseData.intData();
    digitalWrite(LED_PIN, ledStatus == 1 ? HIGH : LOW);
    Serial.println("LED status updated: " + String(ledStatus));
  }

  // Delay 2 detik
  delay(2000);
}