//リモコン
#define IR_PIN 2            // IR Sensor pin

#define IR_BIT_LENGTH 32    // number of bits sent by IR remote
#define FirstLastBit 15     // divide 32 bits into two 15 bit chunks for integer variables. Ignore center two bits. they are all the same.
#define BIT_1 1500          // Binary 1 threshold (Microseconds)
#define BIT_0 450           // Binary 0 threshold (Microseconds)
#define BIT_START 4000      // Start bit threshold (Microseconds)
int remote_verify = 16128;  // verifies first bits are 11111100000000 different remotes may have different start codes

//ディスプレイ
#include <Wire.h>
#define sdaPin 18    // ArduinoA4
#define sclPin 19    // ArduinoA5
#define I2Cadr 0x3e  // 固定
byte contrast = 35;  // コントラスト(0～63)

int scope_num = 3, menu_num = -1;

/* リモコンのキーに割り当てられた整数値を返す関数
 (例：power button ⇒ 整数値1429) */
int get_ir_key()
{
  int pulse[IR_BIT_LENGTH];
  int bits[IR_BIT_LENGTH];

  do {}
  while(pulseIn(IR_PIN, HIGH) < BIT_START);   //Wait for a start bit

  read_pulse(pulse);   // パルス長を読んで
  pulse_to_bits(pulse, bits); // パルス長をビット列に変換して
  RemoteVerify(bits);          // チェックをして
  return bits_to_int(bits);     // ビット列を正数値に変換する
}

/* パルスの長さ[msec] を保存 */
void read_pulse(int pulse[])
{
  for (int i = 0; i < IR_BIT_LENGTH; i++)
  {
        pulse[i] = pulseIn(IR_PIN, HIGH);
  }
}

/* パルスの長さ[msec] をビット列に変換 */
void pulse_to_bits(int pulse[], int bits[])
{
   for (int i = 0; i < IR_BIT_LENGTH; i++) {
      if ( pulse[i] > BIT_1 ) {
          bits[i] = 1;
      } else {
          if ( pulse[i] > BIT_0 ) {
                bits[i] = 0;
            } else {
                Serial.println("Error");
            }
      }
    }
}

/*
  check returns proper first 14 check bits
*/

void RemoteVerify(int bits[])
{
  int result = 0;
  int seed = 1;

  //Convert bits to integer
  for(int i = 0 ; i < (FirstLastBit) ; i++)
  {
    if(bits[i] == 1)
    {
    result += seed;
    }

    seed *= 2;
  }
  //verify first group of bits. delay for data stream to end, then try again.
  if (remote_verify != result) {delay (60); get_ir_key();} 
}


/* ビット列を整数値に変換 */
int bits_to_int(int bits[])
{
  int result = 0;
  int seed = 1;
  for (int i = (IR_BIT_LENGTH-FirstLastBit) ; i < IR_BIT_LENGTH ; i++)
  {
    if (bits[i] == 1) {
        result += seed;
    }
     seed *= 2;
  }
  return result;
}

void setup() {
  pinMode(LED_BUILTIN, OUTPUT);
  pinMode(IR_PIN, INPUT);
  digitalWrite(LED_BUILTIN, LOW);
  Serial.begin(9600);

  //ディスプレイ
  delay( 500 );
  Wire.begin();
  lcd_cmd( 0b00111000 ); // function set
  lcd_cmd( 0b00111001 ); // function set
  lcd_cmd( 0b00000100 ); // EntryModeSet
  lcd_cmd( 0b00010100 ); // interval osc
  lcd_cmd( 0b01110000 | ( contrast & 0xF )); // contrast Low
  lcd_cmd( 0b01011100 | ( ( contrast >> 4 ) & 0x3 )); // contast High/icon/power
  lcd_cmd( 0b01101100 ); // follower control
  delay( 200 );
  lcd_cmd( 0b00111000 ); // function set
  lcd_cmd( 0b00001100 ); // Display On
  lcd_cmd( 0b00000001 ); // Clear Display
  delay( 2 );
}

void loop() {
  //ディスプレイ
  lcd_clear();
  switch (menu_num % 4){
    case 0:
      scope_menu();
      break;
    case 1:
      input_menu1();
      break;
    case 2:
      input_menu2();
      break;
    case 3:
      input_menu3();
      break;
    case -1:
      start();
      break;
    default:
      break;
  }
  
  digitalWrite(LED_BUILTIN, HIGH);
  int key = get_ir_key();

  digitalWrite(LED_BUILTIN, LOW);  // turn LED off while processing response
  do_response(key);
  delay(130);                  // 2 cycle delay to cancel duplicate keypresses
}


void scope_menu(){
  lcd_setCursor( 0, 0 );
  Wire.beginTransmission( I2Cadr );
  lcd_lastdata( byte(0b00000110) );
  Wire.endTransmission();
  lcd_setCursor( 1, 0 );
  lcd_printStr("scope");
  lcd_setCursor( 6, 0 );
  Wire.beginTransmission( I2Cadr );
  lcd_lastdata( byte(0b00000110) );
  Wire.endTransmission();
  lcd_setCursor( 0, 1 );
  Wire.beginTransmission( I2Cadr );
  int n = scope_num;
  while (n > 0){
    lcd_contdata( byte(0b10100000) );
    lcd_contdata( byte(0b01101111) );
    n--;
  }
  n = scope_num;
  while (n < 3){
    lcd_contdata( byte(0b10100000) );
    lcd_contdata( byte(0b11101110) );
    n++;
  }
  Wire.endTransmission();
}

void input_menu1(){
  lcd_setCursor( 0, 0 );
  Wire.beginTransmission( I2Cadr );
  lcd_contdata( byte(0b00010111) );
  lcd_contdata( byte(0b00111010) );
  Wire.endTransmission();
  lcd_printInt(2);
  
  lcd_setCursor( 4, 0 );
  Wire.beginTransmission( I2Cadr );
  lcd_contdata( byte(0b00111110) );
  lcd_contdata( byte(0b00111010) );
  Wire.endTransmission();
  lcd_printInt(6);

  lcd_setCursor( 0, 1 );
  Wire.beginTransmission( I2Cadr );
  lcd_contdata( byte(0b01110110) );
  lcd_contdata( byte(0b00111010) );
  Wire.endTransmission();
  lcd_printInt(8);
  
  lcd_setCursor( 4, 1 );
  Wire.beginTransmission( I2Cadr );
  lcd_contdata( byte(0b00111100) );
  lcd_contdata( byte(0b00111010) );
  Wire.endTransmission();
  lcd_printInt(4);
}

void input_menu2(){
  lcd_setCursor( 0, 0 );
  Wire.beginTransmission( I2Cadr );
  lcd_contdata( byte(0b10111100) );
  lcd_contdata( byte(0b11000011) );
  lcd_contdata( byte(0b11011101) );
  lcd_contdata( byte(0b10110010) );
  lcd_contdata( byte(0b11000100) );
  lcd_contdata( byte(0b11011110) );
  lcd_contdata( byte(0b10110011) );
  Wire.endTransmission();
  
  lcd_setCursor( 0, 1 );
  Wire.beginTransmission( I2Cadr );
  lcd_contdata( byte(0b00000111) );
  lcd_contdata( byte(0b00111010) );
  lcd_contdata( byte(0b11111100) );
  Wire.endTransmission();

  lcd_setCursor( 4, 1 );
  Wire.beginTransmission( I2Cadr );
  lcd_contdata( byte(0b00001000) );
  lcd_contdata( byte(0b00111010) );
  lcd_contdata( byte(0b11111011) );
  Wire.endTransmission();
}

void input_menu3(){
  lcd_setCursor( 0, 0 );
  Wire.beginTransmission( I2Cadr );
  lcd_contdata( byte(0b10111101) );
  lcd_contdata( byte(0b10111010) );
  lcd_contdata( byte(0b10110000) );
  lcd_contdata( byte(0b11001100) );
  lcd_contdata( byte(0b11011111) );
  lcd_contdata( byte(0b00111010) );
  lcd_contdata( byte(0b00111110) );
  lcd_contdata( byte(0b01111100) );
  Wire.endTransmission();
  
  lcd_setCursor( 0, 1 );
  lcd_printInt(scope_num);
  lcd_setCursor( 1, 1 );
  Wire.beginTransmission( I2Cadr );
  lcd_contdata( byte(0b10110110) );
  lcd_contdata( byte(0b10110010) );
  lcd_contdata( byte(0b11000010) );
  lcd_contdata( byte(0b10110110) );
  lcd_contdata( byte(0b10110100) );
  lcd_contdata( byte(0b11011001) );
  Wire.endTransmission();
}

void start(){
  lcd_setCursor( 0, 0 );
  lcd_printStr("");
  lcd_setCursor( 1, 0 );
  Wire.beginTransmission( I2Cadr );
  lcd_contdata( byte(0b10111101) );
  lcd_contdata( byte(0b11000000) );
  lcd_contdata( byte(0b10110000) );
  lcd_contdata( byte(0b11000100) );
  Wire.endTransmission();
  
  lcd_setCursor( 2, 1 );
  Wire.beginTransmission( I2Cadr );
  lcd_contdata( byte(0b00111010) );
  Wire.endTransmission();
  lcd_printStr("POWER");
}


/*
  respond to specific remote-control keys with different behaviors
*/

void do_response(int key)
{
  switch (key)
  {
    case 32640:  // turns on UUT power
//      Serial.println("POWER");
      menu_num++;
      Serial.write("S");
      break;

    case 32385:  // FUNC/STOP turns off UUT power
//      Serial.println("FUNC/STOP");
      break;

    case 32130:  // |<< ReTest failed Test
//      Serial.println("|<<");
      Serial.write("<");
      break;

    case 32002:  // >|| Test
//      Serial.println(">||");
      if (scope_num > 0){
        scope_num--;
      }
      Serial.write("V");
      break;

    case 31875:  // >>| perform selected test number
//      Serial.println(">>|");
      Serial.write(">");
      break;

    case 32512:  // VOL+ turns on individual test beeper
//      Serial.println("VOL+");
      break;

    case 31492:  // VOL- turns off individual test beeper
//      Serial.println("VOL-");
      break;

    case 31620:  // v scroll down tests
//      Serial.println("v");
      break;

    case 31365:  // ^ scroll up tests
//      Serial.println("^");
      menu_num++;
      break;

    case 30982:  // EQ negative tests internal setup
//      Serial.println("EQ");
      break;

    case 30855:  // ST/REPT Positive tests Select Test and Repeat Test
//    Serial.println("ST/REPT");
      break;

    case 31110:  // 0
//      Serial.println("0");
      break;

    case 30600:  // 1
//      Serial.println("1");
      break;

    case 30472:  // 2
      Serial.write("2");
      break;

    case 30345:  // 3
//      Serial.println("3");
      break;

    case 30090:  // 4
      Serial.write("4");
      break;

    case 29962:  // 5
//      Serial.println("5");
      break;

    case 29835:  // 6
      Serial.write("6");
      break;

    case 29580:  // 7
//      Serial.println("7");
      break;

    case 29452:  // 8
      Serial.write("8");
      break;

    case 29325:  // 9
//      Serial.println("9");
      break;

    default:
      {
//        Serial.print("Key ");
//        Serial.print(key);
//        Serial.println(" not programmed");
      }
    break;
  }
}

//ディスプレイ
void lcd_cmd( byte x ) {
  Wire.beginTransmission( I2Cadr );
  Wire.write( 0b00000000 ); // CO = 0,RS = 0
  Wire.write( x );
  Wire.endTransmission();
}
  
void lcd_clear( void ){
  lcd_cmd( 0b00000001 );
}
 
void lcd_contdata( byte x ) {
  Wire.write( 0b11000000 ); // CO = 1, RS = 1
  Wire.write( x );
}
  
void lcd_lastdata( byte x ) {
  Wire.write( 0b01000000 ); // CO = 0, RS = 1
  Wire.write( x );
}
  
// 文字の表示
void lcd_printStr( const char *s ) {
  Wire.beginTransmission( I2Cadr );
  while ( *s ) {
    if ( *(s + 1) ) {
      lcd_contdata( *s );
    } else {
      lcd_lastdata( *s );
    }
    s++;
  }
  Wire.endTransmission();
}
  
// 表示位置の指定
void lcd_setCursor( byte x, byte y ) {
  lcd_cmd( 0x80 | ( y * 0x40 + x ) );
}
 
void lcd_printInt( int num )
{
  char int2str[10];
  sprintf( int2str, "%d", num );
  lcd_printStr( int2str );    
}
