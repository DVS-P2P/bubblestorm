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

package net.bubblestorm.bubbler.android;

import net.bubblestorm.BSError;
import net.bubblestorm.BubbleStorm;
import net.bubblestorm.bubbler.backend.Core;
import net.bubblestorm.bubbler.backend.Subscription;
import android.app.Service;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.IBinder;
import android.util.Log;
import android.widget.Toast;

public class BubblerService extends Service {

	private static final String TAG = "BubblerService";

	// final Messenger mMessenger = new Messenger(new IncomingHandler());

	Core bubblerCore;

	@Override
	public IBinder onBind(Intent intent) {
		return null;
	}

	@Override
	public void onCreate() {
		// toast("Bubbler Service Created");
		Log.d(TAG, "onCreate");

		// Bubbler core
		try {
			bubblerCore = new Core();
		} catch (BSError e) {
			e.printStackTrace();
			toast("Bubbler Error: " + e.getMessage());
		}

		registerReceiver(publishReceiver, new IntentFilter(
				"net.bubblestorm.bubbler.android.PUBLISH"));
		registerReceiver(subscribeReceiver, new IntentFilter(
				"net.bubblestorm.bubbler.android.SUBSCRIBE"));
	}

	@Override
	public void onStart(Intent intent, int startid) {
		toast("Bubbler service starting");
		Log.d(TAG, "onStart");

		final String bootstrapAddr = "localhost";
		final int port = 8585;
		final boolean createRing = true;

		try {
			System.out.println("Connecting to the network...");
			bubblerCore.connect(bootstrapAddr, port, createRing, new BubbleStorm.JoinHandler() {
				@Override
				public void onJoinComplete() {
					Log.d(TAG, "connected.");
					toast("Bubbler connected.");
				}
			});
		} catch (Exception e) {
			e.printStackTrace();
			toast("Bubbler Error: " + e.getMessage());
		}
	}

	@Override
	public void onDestroy() {
		toast("Bubbler Service Stopped");
		Log.d(TAG, "onDestroy");

		unregisterReceiver(subscribeReceiver);
		unregisterReceiver(publishReceiver);
		bubblerCore.shutdown();

		super.onDestroy();
	}

	private void toast(final String text) {
		Toast.makeText(this, text, Toast.LENGTH_LONG).show();
	}

	private final BroadcastReceiver publishReceiver = new BroadcastReceiver() {
		@Override
		public void onReceive(Context context, Intent intent) {
			final CharSequence msg = intent.getExtras().getCharSequence("msg");
			assert(msg != null);
			final CharSequence author = intent.getExtras().getCharSequence("author");
			Log.d(TAG, "Publish: " + msg);

			try {
				bubblerCore.publish((author != null) ? author.toString() : "", msg.toString());
			} catch (Exception e) {
				e.printStackTrace();
				toast("Bubbler Error: " + e.getMessage());
			}
		}
	};

	private final BroadcastReceiver subscribeReceiver = new BroadcastReceiver() {
		@Override
		public void onReceive(Context context, Intent intent) {
			final CharSequence filter = intent.getExtras().getCharSequence("filter");
			Log.d(TAG, "Subscribe: " + filter);

			try {
				bubblerCore.subscribe(filter.toString(), messageHandler);
			} catch (Exception e) {
				e.printStackTrace();
				toast("Bubbler Error: " + e.getMessage());
			}
		}
	};

	private final Subscription.Handler messageHandler = new Subscription.Handler() {

		@Override
		public void onPublish(String author, long timestamp, String content) {
			Log.d(TAG, "Message: " + content + " by " + author);

			Intent in = new Intent("net.bubblestorm.bubbler.android.MESSAGE");
			in.putExtra("author", author);
			in.putExtra("msg", content);
			sendBroadcast(in);
		}

	};

	// private class Receiver extends BroadcastReceiver {
	//
	// @Override
	// public void onReceive(Context context, Intent intent) {
	// final String msg = intent.getExtras().getString("msg");
	//
	// }
	//
	// }

	// private class IncomingHandler extends Handler { // Handler of incoming
	// messages from clients.
	// @Override
	// public void handleMessage(Message msg) {
	// switch (msg.what) {
	// case MSG_REGISTER_CLIENT:
	// mClients.add(msg.replyTo);
	// break;
	// case MSG_UNREGISTER_CLIENT:
	// mClients.remove(msg.replyTo);
	// break;
	// case MSG_SET_INT_VALUE:
	// incrementby = msg.arg1;
	// break;
	// default:
	// super.handleMessage(msg);
	// }
	// }
	// }

}
