package teedomobileapp.teedo.ttt.com.teedomobileapp.asynctasks;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.AsyncTask;
import android.util.Log;

import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.HashMap;

import teedomobileapp.teedo.ttt.com.teedomobileapp.HelperFunctions;
import teedomobileapp.teedo.ttt.com.teedomobileapp.controller.DataStore;
import teedomobileapp.teedo.ttt.com.teedomobileapp.helperClass.UrlHelper;

/**
 * Created by xifengju on 15-04-07.
 */
public class GetImageAsyncTask extends AsyncTask <Void, Void, Bitmap> {
    private Context mContext;
    private String mUserId;

    public GetImageAsyncTask(Context context, String userId) {
        this.mContext = context;
        this.mUserId = userId;
    }

    @Override
    protected Bitmap doInBackground(Void... params) {
        String getImageUrl;
        HashMap<String, String> queryOptions = new HashMap<>();
        queryOptions.put("u", DataStore.getUserName(mContext));
        queryOptions.put("p", DataStore.getHashedPW(mContext));
        String pathUrl = UrlHelper.getPhotoUrl() + mUserId;

        getImageUrl = HelperFunctions.createUrlWithQueries(DataStore.getServerUrl(mContext), pathUrl, queryOptions, mContext);
        Log.e("ImageAsynTask Url is", getImageUrl);

        Bitmap bmp;
        try {
            URL newUrl = new URL(getImageUrl);
            HttpURLConnection con = (HttpURLConnection)newUrl.openConnection();
            InputStream is = con.getInputStream();
            bmp = BitmapFactory.decodeStream(is);
            if (null != bmp)
                return bmp;

        } catch (MalformedURLException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }
    @Override
    protected void onPostExecute (Bitmap resultBmp) {
        DataStore.saveImage(this.mContext, resultBmp, this.mUserId);
    }

}
