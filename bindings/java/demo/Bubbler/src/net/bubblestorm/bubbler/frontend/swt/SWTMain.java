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

package net.bubblestorm.bubbler.frontend.swt;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.util.concurrent.Callable;

import net.bubblestorm.BSError;
import net.bubblestorm.bubbler.backend.Core;
import net.bubblestorm.bubbler.backend.Publication;
import net.bubblestorm.bubbler.backend.Subscription;
import net.bubblestorm.cusp.ChannelIterator;
import net.bubblestorm.cusp.EndPoint;
import net.bubblestorm.cusp.Host;
import net.bubblestorm.cusp.InStreamIterator;
import net.bubblestorm.cusp.OutStreamIterator;
import net.bubblestorm.cusp.Address;
import net.bubblestorm.jni.BSJni;

import org.eclipse.swt.SWT;
import org.eclipse.swt.events.KeyEvent;
import org.eclipse.swt.events.KeyListener;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.events.SelectionListener;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Display;
import org.eclipse.swt.widgets.Event;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Listener;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.TabFolder;
import org.eclipse.swt.widgets.TabItem;
import org.eclipse.swt.widgets.Table;
import org.eclipse.swt.widgets.TableItem;
import org.eclipse.swt.widgets.Text;

public class SWTMain {

	//
	// fields
	//

	private final Core core;

	private Display display;

	private Shell shell;

	private Text textAuthorName;

	private Text textPublish;

	private Table tablePublications;

	private Table tableSubscriptions;

	private Label labelStatus;

	//
	// public methods
	//

	public SWTMain(Core core) {
		this.core = core;
		Display.setAppName("Bubbler");
		display = new Display();
		buildGui();
		createStatusUpdater();
		shell.setSize(640, 400);
		// shell.pack();
	}

	public void run() {
		shell.open();
		while (!shell.isDisposed()) {
			if (!display.readAndDispatch())
				display.sleep();
		}
		display.dispose();
	}

	//
	// protected
	//

	protected void printPublishLn(String text) {
		boolean scroll = (tablePublications.getTopIndex() == 0);
		TableItem item = new TableItem(tablePublications, SWT.NONE, 0);
		item.setText(text);
		if (scroll)
			tablePublications.setTopIndex(0);
	}

	protected void publish(String author, String content) {
		try {
			Publication pub = core.publish(author, content);
			printPublishLn(content + "\n(" + (new Date(pub.getTimestamp())).toString() + ")");
		} catch (Exception e) {
			// TODO error message
			System.err.println("Publish failed:");
			e.printStackTrace();
		}
	}

	protected void setStatusLine(String status) {
		labelStatus.setText(status);
	}

	//
	// private
	//

	private void updatePublications(final Subscription sub) {
		if (sub != null) {
			final ArrayList<Publication> pubs = new ArrayList<Publication>(sub.getPublications());
			tableSubscriptions.setItemCount(0);
			tableSubscriptions.setItemCount(pubs.size());
			tableSubscriptions.setData(pubs);
		} else {
			tableSubscriptions.setItemCount(0);
			tableSubscriptions.setData(null);
		}
		tableSubscriptions.update();
	}

	private void buildGui() {
		shell = new Shell(display);
		shell.setText("Bubbler");
		// shell.setLayout(new RowLayout(SWT.HORIZONTAL));

		final Composite compMain = shell;// new Composite(shell, SWT.NONE);
		final GridLayout compMainLayout = new GridLayout(1, false);
		compMain.setLayout(compMainLayout);

		// main control panel (top)
		final Composite compMainCtrl = new Composite(compMain, SWT.NONE);
		compMainCtrl.setLayoutData(new GridData(SWT.FILL, SWT.FILL, true, false));
		final GridLayout compMainCtrlLayout = new GridLayout(3, false);
		compMainCtrl.setLayout(compMainCtrlLayout);

		textAuthorName = new Text(compMainCtrl, SWT.SINGLE | SWT.BORDER);
		textAuthorName.setLayoutData(new GridData(SWT.BEGINNING, SWT.CENTER, false, false));
		textAuthorName.setText("anonymous");

		textPublish = new Text(compMainCtrl, SWT.SINGLE | SWT.BORDER);
		textPublish.setLayoutData(new GridData(SWT.FILL, SWT.CENTER, true, false));
		textPublish.setFocus();
		textPublish.addKeyListener(new KeyListener() {
			@Override
			public void keyReleased(KeyEvent e) {
			}

			@Override
			public void keyPressed(KeyEvent e) {
				if (e.keyCode == '\r') {
					publish(textAuthorName.getText(), textPublish.getText());
					textPublish.setText("");
				}
			}
		});

		final Button btnPublish = new Button(compMainCtrl, SWT.PUSH);
		btnPublish.setLayoutData(new GridData(SWT.BEGINNING, SWT.CENTER, false, false));
		btnPublish.setText("Publish");
		btnPublish.addSelectionListener(new SelectionListener() {
			@Override
			public void widgetSelected(SelectionEvent e) {
				publish(textAuthorName.getText(), textPublish.getText());
				textPublish.setText("");
			}

			@Override
			public void widgetDefaultSelected(SelectionEvent e) {
			}
		});

		// subscription view
		final TabFolder tabSubscriptions = new TabFolder(compMain, SWT.TOP);
		tabSubscriptions.setLayoutData(new GridData(SWT.FILL, SWT.FILL, true, true));
		final TabItem itemPublications = new TabItem(tabSubscriptions, SWT.NONE);
		itemPublications.setText("My Publications");
		tablePublications = new Table(tabSubscriptions, SWT.MULTI | SWT.FULL_SELECTION | SWT.BORDER);
		itemPublications.setControl(tablePublications);

		final TabItem itemNewTab = new TabItem(tabSubscriptions, SWT.NONE);
		itemNewTab.setText(" + ");
		tableSubscriptions = new Table(tabSubscriptions, SWT.VIRTUAL | SWT.MULTI
				| SWT.FULL_SELECTION | SWT.BORDER);
		tableSubscriptions.addListener(SWT.SetData, new Listener() {
			@SuppressWarnings("unchecked")
			public void handleEvent(Event event) {
				TableItem item = (TableItem) event.item;
				Object pubsObj = tableSubscriptions.getData();
				if (pubsObj != null) {
					List<Publication> pubs = (List<Publication>) pubsObj;
					int index = tableSubscriptions.indexOf(item);
					Publication pub = pubs.get(index);
					item.setText(pub.getContent() + "\n("
							+ (new Date(pub.getTimestamp())).toString() + " by " + pub.getAuthor()
							+ ")");
					// System.out.println(item.getText());
				}
			}
		});

		tabSubscriptions.addSelectionListener(new SelectionListener() {
			@Override
			public void widgetSelected(SelectionEvent e) {
				TabItem item = (TabItem) e.item;
				if (item == itemNewTab) {
					InputBox input = new InputBox(shell, SWT.APPLICATION_MODAL);
					input.setText("New Subscription");
					input.setMessage("Subscription filter:");
					final String filter = input.open();
					// add subscription
					if (filter != null) {
						try {
							int idx = tabSubscriptions.getSelectionIndex();
							final TabItem itemSub = new TabItem(tabSubscriptions, SWT.NONE, idx);
							itemSub.setText("Sub: " + filter);
							itemSub.setControl(tableSubscriptions);
							final Subscription sub = core.subscribe(filter,
									new Subscription.Handler() {
										@Override
										public void onPublish(String author, long timestamp,
												String content) {
											display.asyncExec(new Runnable() {
												@Override
												public void run() {
													if (Arrays.asList(
															tabSubscriptions.getSelection())
															.contains(itemSub)) {
														final Object subObj = itemSub.getData();
														if (subObj instanceof Subscription) {
															updatePublications((Subscription) subObj);
														} else {
															updatePublications(null);
														}
													} else {
														// add 'new' tag
														final String text = itemSub.getText();
														if (!text.startsWith("* "))
															itemSub.setText("* " + text);
													}
												}
											});
										}
									});
							itemSub.setData(sub);
							tabSubscriptions.setSelection(idx);
							updatePublications(sub);
						} catch (Exception ex) {
							// TODO error message
							ex.printStackTrace();
						}
					} else
						tabSubscriptions.setSelection(0);
				} else {
					// remove 'new' tag
					final String text = item.getText();
					if (text.startsWith("* "))
						item.setText(text.substring(2));

					final Object subObj = item.getData();
					if (subObj instanceof Subscription) {
						updatePublications((Subscription) subObj);
					} else {
						updatePublications(null);
					}
				}
			}

			@Override
			public void widgetDefaultSelected(SelectionEvent e) {
			}
		});

		// status line
		labelStatus = new Label(compMain, SWT.NONE);
		labelStatus.setLayoutData(new GridData(SWT.FILL, SWT.FILL, true, false));
		labelStatus.setText("\n\n"); // 3-line text
	}

	private void createStatusUpdater() {
		(new Thread() {
			@Override
			public void run() {
				while (!display.isDisposed()) {
					try {
						// build info string (run in BS thread to avoid too many
						// thread switches)
						final String statusLine = BSJni.call(new Callable<String>() {
							@Override
							public String call() throws Exception {
								final EndPoint ep = core.endpoint();
								int channels = 0;
								int inStreams = 0;
								int outStreams = 0;
								for (ChannelIterator cit = ep.channels(); cit.hasNext(); channels++) {
									Host host = cit.next().getB();
									if (host != null) {
										for (InStreamIterator isit = host.inStreams(); isit
												.hasNext(); inStreams++)
											isit.next();
										for (OutStreamIterator osit = host.outStreams(); osit
												.hasNext(); outStreams++)
											osit.next();
									}
								}
								Address myAddr = core.localAddress();
								return "Publish bubble: "
										+ Integer.toString(core.publishBubbleSize())
										+ "   Subscribe bubble: "
										+ Integer.toString(core.subscribeBubbleSize())
										+ "\nBytes up: " + Long.toString(ep.bytesSent())
										+ "   Bytes down: " + Long.toString(ep.bytesReceived())
										+ "   Channels: " + Integer.toString(channels)
										+ "   Streams: " + Integer.toString(inStreams + outStreams)
										+ " (" + Integer.toString(inStreams) + " + "
										+ Integer.toString(outStreams) + ")" + "\nMy address: "
										+ ((myAddr != null) ? myAddr.toString() : "?")
										+ "   Recv UDP: "
										+ Boolean.toString(core.endpoint().canReceiveUDP())
										+ "   Send ICMP: "
										+ Boolean.toString(core.endpoint().canSendOwnICMP());
							}
						});
						// display string
						display.asyncExec(new Runnable() {
							@Override
							public void run() {
								if (!display.isDisposed()) {
									setStatusLine(statusLine);
								}
							}
						});
						Thread.sleep(2000);
					} catch (BSError e) {
						e.printStackTrace();
					} catch (InterruptedException e) {
					}
				}
			}
		}).start();
	}
}
