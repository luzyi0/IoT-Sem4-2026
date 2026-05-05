#include <WiFi.h>
#include <FirebaseESP32.h>
#include "DHT.h"

// Kredensial Akses
#define WIFI_SSID "Sutikno-EXT"
#define WIFI_PASSWORD "131464637"
#define API_KEY "AIzaSyABHv8mytSUkY6C0eN4iaTQKOH3rZrf2NA"
#define DATABASE_URL "iotia-e79cb-default-rtdb.firebaseio.com" 
#define USER_EMAIL "iotia2026ti2b@gmail.com"
#define USER_PASSWORD "12345678"

// Definisi Pin
#define DHTPIN 4
#define DHTTYPE DHT11
#define LED_PIN 2

DHT dht(DHTPIN, DHTTYPE);
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

// Nama Parent Node di Firebase
String parentPath = "/esiot-db";

void setup() {
  Serial.begin(115200);
  pinMode(LED_PIN, OUTPUT);
  dht.begin();

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi Connected!");

  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
}

void loop() {
  // --- BAGIAN 1: MENGIRIM DATA SENSOR ---
  float h = dht.readHumidity();
  float t = dht.readTemperature();

  if (!isnan(h) && !isnan(t)) {
    // Update data ke /esiot-db/kelembapan dan /esiot-db/suhu
    Firebase.setFloat(fbdo, parentPath + "/kelembapan", h);
    Firebase.setFloat(fbdo, parentPath + "/suhu", t);
    
    Serial.printf("Suhu: %.1f | Kelembapan: %.1f\n", t, h);
  }

  // --- BAGIAN 2: MENGONTROL LED DARI FIREBASE ---
  // Membaca status dari /esiot-db/led
  if (Firebase.getInt(fbdo, parentPath + "/led")) {
    int ledStatus = fbdo.intData();
    digitalWrite(LED_PIN, ledStatus == 1 ? HIGH : LOW);
    Serial.printf("Status LED di DB: %d\n", ledStatus);
  }

  delay(3000); // Sinkronisasi setiap 3 detik
}