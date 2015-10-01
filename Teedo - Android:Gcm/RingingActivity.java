package teedomobileapp.teedo.ttt.com.teedomobileapp;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;


import teedomobileapp.teedo.ttt.com.teedomobileapp.Gcmhelper.GcmHelperFunction;
import teedomobileapp.teedo.ttt.com.teedomobileapp.asynctasks.CallActionAsyncTask;
import teedomobileapp.teedo.ttt.com.teedomobileapp.controller.DataStore;
import teedomobileapp.teedo.ttt.com.teedomobileapp.helperClass.ImageHelper;


public class RingingActivity extends Activity {
    private Handler handler = new Handler();
    private boolean isOutgoingCall = false;
    private TextView mCallingText;
    private String mFirstName;
    private String mLastName;
    private String mCaller;
    private boolean mHas_video;
    private ImageView mUserImageView;

    public static RingingActivity ca;
    private MediaPlayer mMediaPlayer;
    private boolean isRining;
    @Override
    protected void onCreate(Bundle savedInstanceState){
        super.onCreate(savedInstanceState);
        ca = this;
        setContentView(R.layout.activity_call_ring);
        this.mCallingText = (TextView) findViewById(R.id.ringingText);
        this.mUserImageView = (ImageView) findViewById(R.id.ringingPhoto);
        init();
    }

    private void init(){
        //initialize the activity
        isRining = false;
        isOutgoingCall = getIntent().getBooleanExtra("isOutgoingCall", false);
        this.mCaller = getIntent().getStringExtra("caller");
        this.mHas_video = getIntent().getBooleanExtra("has_video", false);

       //set the ringing image
        this.mUserImageView.setImageBitmap(ImageHelper.convertBitmapToRoundedWhiteBorder(DataStore.getImageBitmap(this, this.mCaller), 600));

        // get the caller/callee first name and last name
        this.mFirstName = DataStore.getTabletFirstName(this);
        this.mLastName = DataStore.getTabletLastName(this);

        if (isOutgoingCall){

            this.mCallingText.setText("Calling " + this.mFirstName + "...");
            //hide answerButton and declineButton
            ImageView btnAnswer = (ImageView) findViewById(R.id.btnAnswer);
            btnAnswer.setVisibility(View.INVISIBLE);
            ImageView btnDecline = (ImageView) findViewById(R.id.btnDecline);
            btnDecline.setVisibility(View.INVISIBLE);

            // hide answerLabel and declineLabel
            TextView btnAnswerLabel = (TextView) findViewById(R.id.btnAnswerLabel);
            btnAnswerLabel.setVisibility(View.INVISIBLE);
            TextView btnDeclineLabel = (TextView) findViewById(R.id.btnDeclineLabel);
            btnDeclineLabel.setVisibility(View.INVISIBLE);

        }else{
            GcmHelperFunction.wakeUpScreen(this);
            this.mCallingText.setText("Incoming call from " + this.mFirstName + "...");
            ImageView btnCancel = (ImageView) findViewById(R.id.btnCancel);
            btnCancel.setVisibility(View.INVISIBLE);
            TextView btnCancelLabel = (TextView) findViewById(R.id.btnCancelLabel);
            btnCancelLabel.setVisibility(View.INVISIBLE);
            ringTone();
        }

        handler.removeCallbacks(returnToMainRunnable);
        handler.postDelayed(returnToMainRunnable, DataStore.RINGING_TIMEOUT);
    }


    public void answerBtnHandler(View v){
        //send confrimation url
        new CallActionAsyncTask(getBaseContext(), DataStore.e_GcmAnswer, this.mCaller).execute();
        Intent newIntent = new Intent(RingingActivity.ca, AudioVideoCallingAcitivity.class);
        newIntent.putExtra("has_video", mHas_video);
        newIntent.putExtra("caller", this.mCaller);
        RingingActivity.ca.finish();
        newIntent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK
                | Intent.FLAG_ACTIVITY_CLEAR_TOP);
        startActivity(newIntent);

    }

    public void declineBtnHandler(View v){
        new CallActionAsyncTask(getBaseContext(), DataStore.e_GcmDecline, this.mCaller).execute();
        finish();
    }

    public void cancelBtnHandler(View v){
        new CallActionAsyncTask(getBaseContext(), DataStore.e_GcmCancel, this.mCaller).execute();
        finish();
    }

    @Override
    protected void onDestroy(){
        super.onDestroy();
        stopRining();
        handler.removeCallbacksAndMessages(null);
        ca = null;
    }

    public void ringingConfirmed() {
        if (!isRining) {
            isRining = true;
            this.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    ((TextView) findViewById(R.id.ringingText)).setText("Ringing " + mFirstName + "...");
                    ringTone();

                }
            });
        }
    }

    private void ringTone() {
        if( mMediaPlayer == null ) {
            if (isOutgoingCall) {
                mMediaPlayer = MediaPlayer.create(this, R.raw.calling);
            } else {
                mMediaPlayer = MediaPlayer.create(this, R.raw.ringtone);
            }
            mMediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
            mMediaPlayer.setLooping(true);
            mMediaPlayer.seekTo(0);
            mMediaPlayer.start();

            AudioManager am = (AudioManager) getSystemService(Context.AUDIO_SERVICE);
            am.setMode(AudioManager.STREAM_MUSIC);
            if (isOutgoingCall && !mHas_video) {
                am.setSpeakerphoneOn(false);
            } else {
                am.setSpeakerphoneOn(true);
            }
        }
    }

    private void stopRining() {
        if (mMediaPlayer != null) {
            mMediaPlayer.stop();
            mMediaPlayer.release();
            mMediaPlayer = null;
        }
    }


    public boolean isVideo(){
        return mHas_video;
    }
    public String getCaller() {return mCaller;}

    private Runnable returnToMainRunnable = new Runnable() {
        @Override
        public void run() {
            if (RingingActivity.ca != null) {
                finish();
                Intent newIntent = new Intent(RingingActivity.ca, CallSummaryActivity.class);
                newIntent.putExtra("caller", RingingActivity.ca.getCaller());
                newIntent.putExtra("err", DataStore.e_CallErr_OutTimedOut);
                startActivity(newIntent);
            }
        }
    };
}
