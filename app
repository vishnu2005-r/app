geocode,location based services,
package com.example.myapplication8

@Suppress("DEPRECATION")
class MainActivity : AppCompatActivity() {
    private lateinit var location: FusedLocationProviderClient
    private lateinit var textview:TextView
    private lateinit var getlocation:TextView
    private lateinit var getlocationbutton: Button
   private lateinit var submit:Button
    private lateinit var sendsms:Button
    @SuppressLint("MissingInflatedId")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.activity_main)
        textview=findViewById(R.id.textView)
        getlocation=findViewById(R.id.textView2)
        getlocationbutton=findViewById(R.id.button)
        submit=findViewById(R.id.button2)
        sendsms=findViewById(R.id.button5)

        location=LocationServices.getFusedLocationProviderClient(this)


        val latitude = 9.9129
        val longitude = 78.1477
        val address=findlocation(latitude,longitude)
        textview.text= address ?: "address not found"

        getlocationbutton.setOnClickListener {
            getCurrentLocation()
        }
        submit.setOnClickListener{
            val intent=Intent(this,MainActivity2::class.java)
            startActivity(intent)
        }
        sendsms.setOnClickListener{
            val sms=SmsManager.getDefault()
            sms.sendTextMessage("9360307352",null,"you joined the quizz",null,null)
        }
    }
    private fun findlocation(lat: Double, long: Double): String? {
        return  try{
            val geocoder=Geocoder(this, Locale.getDefault())
            val addresss=geocoder.getFromLocation(lat,long,1)
            if(!addresss.isNullOrEmpty()){
                val address=addresss[0]
                "${address.getAddressLine(0)},${address.locality},${address.countryName}"
            }
            else{
                "No address found"
            }
        }catch (e:Exception){
            e.printStackTrace()
            "Error fetching"
        }

    }
    private  fun getCurrentLocation(){
        if (ActivityCompat.checkSelfPermission(
                this,
                Manifest.permission.ACCESS_FINE_LOCATION
            ) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(
                this,
                Manifest.permission.ACCESS_COARSE_LOCATION
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            // TODO: Consider calling
            //    ActivityCompat#requestPermissions
            // here to request the missing permissions, and then overriding
            //   public void onRequestPermissionsResult(int requestCode, String[] permissions,
            //                                          int[] grantResults)
            // to handle the case where the user grants the permission. See the documentation
            // for ActivityCompat#requestPermissions for more details.
            return
        }
        location.lastLocation.addOnSuccessListener{
            if(it!=null){
                Toast.makeText(this,"lattitude:${it.latitude} longitude:${it.longitude}",Toast.LENGTH_LONG).show()
            }
            else{
                Toast.makeText(this,"loction is not availabe",Toast.LENGTH_LONG).show()
            }
        }
    }
}
menu,sqlite,notification
...........................


class MainActivity2 : AppCompatActivity() {
    private lateinit var popnuttom: Button
    private lateinit var colorview:TextView
    private lateinit var addbuttom: Button
    private lateinit var deletebuttom: Button
    private lateinit var viewbuttom: Button
    private lateinit var updatebuttom: Button
    private lateinit var ename: EditText
    private lateinit var eage: EditText
    private lateinit var output:TextView
    private lateinit var dbHelper: DatabaseHelper
    private lateinit var sendnot: Button

    private lateinit var database: SQLiteDatabase

    @SuppressLint("MissingInflatedId")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.activity_main2)
        popnuttom=findViewById(R.id.button3)
        sendnot=findViewById(R.id.button8)
        colorview=findViewById(R.id.textView3)
        addbuttom=findViewById(R.id.button4)
        deletebuttom=findViewById(R.id.deleteButton)
        viewbuttom=findViewById(R.id.button7)
        updatebuttom=findViewById(R.id.button6)
        ename=findViewById(R.id.editTextText)
        eage=findViewById(R.id.editTextText2)
        output=findViewById(R.id.textView4)
        registerForContextMenu(colorview)
        dbHelper=DatabaseHelper(this)
        database=dbHelper.writableDatabase

        addbuttom.setOnClickListener{
            adddata()
        }
        viewbuttom.setOnClickListener{
            viewdata()
        }
        deletebuttom.setOnClickListener{
            deleteData()
        }
        updatebuttom.setOnClickListener{
            updateData()
        }

        popnuttom.setOnClickListener{
            val pop:PopupMenu=PopupMenu(this,popnuttom)
            pop.menuInflater.inflate(R.menu.popmenu,pop.menu)
            pop.setOnMenuItemClickListener(PopupMenu.OnMenuItemClickListener {
                item->
                when (item.itemId){
                    R.id.javaid ->
                    Toast.makeText(this,"java course clicked",Toast.LENGTH_LONG).show()
                    R.id.cid  ->
                    Toast.makeText(this,"c course clicked",Toast.LENGTH_LONG).show()
                }
                 true
            })
            pop.show()
        }
       if(Build.VERSION.SDK_INT>=Build.VERSION_CODES.O){
           val channel=NotificationChannel("channelid","mychannel",NotificationManager.IMPORTANCE_DEFAULT)
           val manager=getSystemService(NotificationManager::class.java)
           manager.createNotificationChannel(channel)
       }

        sendnot.setOnLongClickListener {
            val builder=NotificationCompat.Builder(this,"channelid")
                .setSmallIcon(R.drawable.ic_launcher_foreground)
                .setContentTitle("hi")
                .setContentText("you successfull joined this quiz")
                .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            if (ActivityCompat.checkSelfPermission(
                    this,
                    Manifest.permission.POST_NOTIFICATIONS
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                // TODO: Consider calling
                //    ActivityCompat#requestPermissions
                // here to request the missing permissions, and then overriding
                //   public void onRequestPermissionsResult(int requestCode, String[] permissions,
                //                                          int[] grantResults)
                // to handle the case where the user grants the permission. See the documentation
                // for ActivityCompat#requestPermissions for more details.
                return@setOnLongClickListener true
            }
            NotificationManagerCompat.from(this).notify(1,builder.build())
            true
        }


    }

    private fun viewdata() {
        val cursor:Cursor=database.rawQuery("SELECT * FROM user",null)
            val data=StringBuilder()
            if(cursor.moveToFirst()){
                do {
                    val id=cursor.getInt(0)
                    val name=cursor.getString(1)
                    val age=cursor.getString(2)
                    data.append("id :$id, name:$name,age:$age")
                }while (cursor.moveToNext())
            }
        cursor.close()
        output.text=data.toString()
    }

    private fun adddata() {
        val name=ename.text.toString()
        val age=eage.text.toString()
        if(name.isNotEmpty() && age.isNotEmpty()){
            val values=ContentValues().apply{
                put("name",name)
                put("age",age)
            }
            database.insert("user",null,values)
            Toast.makeText(this, "Data Inserted",
                Toast.LENGTH_SHORT).show()
        }
    }
    private fun deleteData() {
        val name = ename.text.toString()
        if (name.isNotEmpty()) {
             database.delete("user", "name=?", arrayOf(name))
            Toast.makeText(this, "Deleted" , Toast.LENGTH_SHORT).show()
        } else {
            Toast.makeText(this, "Enter name to delete", Toast.LENGTH_SHORT).show()
        }
    }

    private fun updateData() {
        val name = ename.text.toString()
        val age = eage.text.toString()
        if (name.isNotEmpty() && age.isNotEmpty()) {
            val values = ContentValues().apply {
                put("age", age)
            }
             database.update("user", values, "name=?", arrayOf(name))
            Toast.makeText(this,  "Updated" , Toast.LENGTH_SHORT).show()
        } else {
            Toast.makeText(this, "Enter both name and age", Toast.LENGTH_SHORT).show()
        }
    }

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.menu,menu)
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        return when(item.itemId){
            R.id.item1->{
                Toast.makeText(this,"Setting selected",Toast.LENGTH_LONG).show()
                true
            }
            R.id.item2->{
                Toast.makeText(this,"about selected",Toast.LENGTH_LONG).show()
                return true
            }
            else ->super.onOptionsItemSelected(item)
        }
    }

    override fun onCreateContextMenu(
        menu: ContextMenu?,
        v: View?,
        menuInfo: ContextMenu.ContextMenuInfo?
    ) {
        super.onCreateContextMenu(menu, v, menuInfo)
        if(v?.id==R.id.textView3){
            menuInflater.inflate(R.menu.contextmenu,menu)

        }
    }

    override fun onContextItemSelected(item: MenuItem): Boolean {
        return when(item.itemId){
            R.id.redid->{
                colorview.setTextColor(Color.RED)
             true
            }
            R.id.blueid->{
                colorview.setTextColor(Color.BLUE)
                true
            }


            else -> super.onContextItemSelected(item)
        }
    }
}

.............
package com.example.myapplication8

import android.content.Context
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper

class DatabaseHelper(context: Context) : SQLiteOpenHelper(context,Databasename,null,databaseversion){
    companion object{
        private const val Databasename="userdatabase.db"
        private const val databaseversion=1
        private const val table="user"
        private const val createTable="""
           CREATE TABLE $table(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            age TEXT
           )
        """
    }

    override fun onCreate(db: SQLiteDatabase?) {
        db?.execSQL(createTable)
    }

    override fun onUpgrade(db: SQLiteDatabase?, oldVersion: Int, newVersion: Int) {

        db?.execSQL("DROP TABLE IF EXISTS user")
        onCreate(db)
    }
}

alert,sharedpreference,datepicker
............

class MainActivity2 : AppCompatActivity() {
    private lateinit var ename:EditText

    private lateinit var eage:EditText
    private lateinit var enumber:EditText
    private lateinit var sendsms:Button
    private lateinit var btnsave:Button
    private lateinit var btnview:Button
    private lateinit var btnclear:Button
    private lateinit var outputview:TextView
    private lateinit var outputage:TextView
    private lateinit var textShown:TextView
    private lateinit var dateNeed:CalendarView
    companion object{
        const val SMS_PERMISSION_CODE=101
    }
    @SuppressLint("MissingInflatedId")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.activity_main2)
        ename=findViewById(R.id.editTextText)
        eage=findViewById(R.id.editTextText2)
        enumber=findViewById(R.id.editTextText4)
        sendsms=findViewById(R.id.button7)
        btnsave=findViewById(R.id.button8)
        btnview=findViewById(R.id.button9)
        btnclear=findViewById(R.id.button10)
        outputview=findViewById(R.id.textView2)
        outputage=findViewById(R.id.textView3)
        var submit = findViewById<Button>(R.id.button6)

        textShown = findViewById(R.id.textView4)
        dateNeed = findViewById(R.id.calendarView)

        dateNeed.setOnDateChangeListener { _, year, month, dayOfMonth ->
            val selectedDate = "Date: $dayOfMonth/${month + 1}/$year"
            textShown.text = selectedDate
        }

        submit.setOnClickListener{
            val edt=ename.text.toString().trim()
            if(edt.isEmpty()){
                AlertDialog.Builder(this)
                    .setTitle("input requires")
                    .setMessage("please enter details")
                    .setPositiveButton("ok",null)
                    .setNegativeButton("close",null)
                    .show()
            }
        }

        val sharedpreference : SharedPreferences=this.getSharedPreferences("my pref",Context.MODE_PRIVATE)

        btnsave.setOnClickListener {
            val name=ename.text.toString()
            val age=eage.text.toString()
            val editor:SharedPreferences.Editor=sharedpreference.edit()
            editor.putString("namekey",name)
            editor.putString("idkey",age)
            editor.apply()


        }

        btnview.setOnClickListener {
            val getage = sharedpreference.getString("idkey", "defaultage")
            val getname = sharedpreference.getString("namekey", "default")
            outputview.text = "Name: $getname"
            outputage.text = "Age: $getage"
        }

        btnclear.setOnClickListener {
            val editor=sharedpreference.edit()
            editor.apply()
            outputview.setText("").toString()
            outputage.setText("").toString()
        }


    }




    }




