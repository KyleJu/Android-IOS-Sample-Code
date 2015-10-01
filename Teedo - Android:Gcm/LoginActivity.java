package teedomobileapp.teedo.ttt.com.teedomobileapp;

import android.content.Intent;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.AsyncTask;
import android.provider.ContactsContract;
import android.support.v7.app.ActionBarActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import org.json.JSONException;
import org.json.JSONObject;

import teedomobileapp.teedo.ttt.com.teedomobileapp.asynctasks.GetContactsAsyncTask;
import teedomobileapp.teedo.ttt.com.teedomobileapp.asynctasks.GetImageAsyncTask;
import teedomobileapp.teedo.ttt.com.teedomobileapp.asynctasks.LoginAsyncTask;
import teedomobileapp.teedo.ttt.com.teedomobileapp.controller.DataStore;
import teedomobileapp.teedo.ttt.com.teedomobileapp.interfaces.LoginInterface;


public class LoginActivity extends ActionBarActivity implements LoginInterface{

    private EditText mUsernameEditText;
    private EditText mPasswordEditText;
    private Button mLoginbutton;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);

        String username = DataStore.getUserName(this);
        if (username != "") {
            Intent mainIntent = new Intent(LoginActivity.this, MainActivity.class);
            this.startActivity(mainIntent);
        }

        mUsernameEditText = (EditText) findViewById(R.id.username_edittext);
        mPasswordEditText = (EditText) findViewById(R.id.password_edittext);
        mPasswordEditText.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
                boolean handled = false;
                if (actionId == EditorInfo.IME_ACTION_DONE) {
                    sendLoginInfo();
                    handled = true;
                }
                return handled;
            }
        });
        mLoginbutton = (Button) findViewById(R.id.login_button);
        mLoginbutton.setOnClickListener(new MyOnclickListener());
    }

    @Override
    public void onSuccess(JSONObject userinfo) {
        try {
            DataStore.setUID(userinfo.getString("uid"), this);
            DataStore.setServerUrl(userinfo.getString("server"), this);
            DataStore.setNotificationBaseUrl(userinfo.getString("server"), this);
            DataStore.setUserName(mUsernameEditText.getText().toString(), this);
            DataStore.setStringPassword(mPasswordEditText.getText().toString(), this);
            DataStore.setHashedPW(HelperFunctions.hashPassword(mPasswordEditText.getText().toString()), this);
            new GetContactsAsyncTask(this, LoginActivity.this).executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onFailure() {

        Toast.makeText(this, "failed to login", Toast.LENGTH_LONG).show();
    }

    @Override
    public void starMainActivity() {
        Intent mainIntent = new Intent(LoginActivity.this, MainActivity.class);
        this.startActivity(mainIntent);
    }

    private class MyOnclickListener implements View.OnClickListener{

        @Override
        public void onClick(View v) {
            switch(v.getId()){
                case R.id.login_button:
                    sendLoginInfo();
                    break;
            }
        }
    }

    private void sendLoginInfo () {
        String uname = mUsernameEditText.getText().toString();
        String pword = mPasswordEditText.getText().toString();
        new LoginAsyncTask(uname, pword, LoginActivity.this, LoginActivity.this).executeOnExecutor(AsyncTask.THREAD_POOL_EXECUTOR);
    }



}
