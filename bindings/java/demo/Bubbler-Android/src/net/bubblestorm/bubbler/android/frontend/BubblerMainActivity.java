/*
	This file is part of BubbleStorm.
	Copyright © 2008-2013 the BubbleStorm authors

	BubbleStorm is free software: you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation, either version 3 of the License, or
	(at your option) any later version.

	BubbleStorm is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with BubbleStorm.  If not, see <http://www.gnu.org/licenses/>.
*/

package net.bubblestorm.bubbler.android.frontend;

import net.bubblestorm.bubbler.android.BubblerService;
import net.bubblestorm.bubbler.android.R;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.util.Log;
import android.view.Menu;
import android.view.View;
import android.widget.TextView;
import android.widget.ToggleButton;

public class BubblerMainActivity extends Activity {

	private static final String TAG = "BubblerMainActivity";

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_bubbler_main);
		registerReceiver(messageReceiver, new IntentFilter(
				"net.bubblestorm.bubbler.android.MESSAGE"));
	}

	@Override
	protected void onDestroy() {
		unregisterReceiver(messageReceiver);
		super.onDestroy();
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		getMenuInflater().inflate(R.menu.activity_bubbler_main, menu);
		return true;
	}

	public void onServiceButtonClick(View view) {
		final ToggleButton b = (ToggleButton) view;
		if (b.isChecked()) {
			Log.d(TAG, "onClick: starting service");
			startService(new Intent(this, BubblerService.class));
		} else {
			Log.d(TAG, "onClick: stopping service");
			stopService(new Intent(this, BubblerService.class));
		}
	}

	public void onSubscribeClick(View view) {
		final TextView ed = (TextView) findViewById(R.id.editSubscribe);
		final CharSequence filter = ed.getText();
		ed.setText("");
//		logMessage(filter);
		
		Intent in = new Intent("net.bubblestorm.bubbler.android.SUBSCRIBE");
		in.putExtra("filter", filter);
		sendBroadcast(in);
	}

	public void onPublishClick(View view) {
		final TextView ed = (TextView) findViewById(R.id.editPublish);
		final CharSequence msg = ed.getText();
		ed.setText("");
//		logMessage(msg);
		
		Intent in = new Intent("net.bubblestorm.bubbler.android.PUBLISH");
		in.putExtra("msg", msg);
		sendBroadcast(in);
	}

	private void logMessage(final CharSequence text) {
		final TextView log = (TextView) findViewById(R.id.textMessageLog);
		log.append("\n");
		log.append(text);
	}

	private final BroadcastReceiver messageReceiver = new BroadcastReceiver() {
		@Override
		public void onReceive(Context context, Intent intent) {
			final CharSequence msg = intent.getExtras().getCharSequence("msg");
			logMessage("Message: " + msg);
		}
	};

}
