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

import org.eclipse.swt.SWT;
import org.eclipse.swt.events.SelectionAdapter;
import org.eclipse.swt.events.SelectionEvent;
import org.eclipse.swt.layout.GridData;
import org.eclipse.swt.layout.GridLayout;
import org.eclipse.swt.layout.RowLayout;
import org.eclipse.swt.widgets.Button;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Dialog;
import org.eclipse.swt.widgets.Label;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.swt.widgets.Text;

public class InputBox extends Dialog {
	private Shell shell;
	private Label label;

	private String message;
	private String result;

	public InputBox(Shell parent, int style) {
		super(parent, checkStyle(style));

		shell = new Shell(parent, SWT.DIALOG_TRIM | checkStyle(style));
		shell.setText(getText());
		shell.setLayout(new GridLayout(2, false));

		new Label(shell, SWT.CENTER).setImage(shell.getDisplay().getSystemImage(
				checkImageStyle(style)));

		Composite body = new Composite(shell, SWT.NONE);

		GridData data0 = new GridData();
		data0.grabExcessHorizontalSpace = true;
		data0.grabExcessVerticalSpace = true;
		data0.horizontalAlignment = SWT.FILL;
		data0.verticalAlignment = SWT.FILL;
		body.setLayoutData(data0);

		body.setLayout(new GridLayout());

		label = new Label(body, SWT.LEFT);

		GridData data1 = new GridData();
		data1.grabExcessHorizontalSpace = true;
		data1.grabExcessVerticalSpace = true;
		data1.horizontalAlignment = SWT.FILL;
		data1.verticalAlignment = SWT.FILL;
		label.setLayoutData(data1);

		final Text text = new Text(body, SWT.SINGLE | SWT.BORDER);

		GridData data2 = new GridData();
		data2.grabExcessHorizontalSpace = true;
		data2.horizontalAlignment = SWT.FILL;
		text.setLayoutData(data2);

		Composite footer = new Composite(shell, SWT.NONE);

		GridData data3 = new GridData();
		data3.grabExcessHorizontalSpace = true;
		data3.horizontalAlignment = SWT.FILL;
		data3.horizontalSpan = 2;
		footer.setLayoutData(data3);

		RowLayout layout = new RowLayout();
		layout.justify = true;
		layout.fill = true;
		footer.setLayout(layout);

		Button cancel = new Button(footer, SWT.PUSH);
		cancel.setText("  Cancel  ");
		cancel.addSelectionListener(new SelectionAdapter() {
			public void widgetSelected(SelectionEvent e) {
				shell.dispose();
			}
		});

		Button ok = new Button(footer, SWT.PUSH);
		ok.setText("    OK    ");
		ok.addSelectionListener(new SelectionAdapter() {
			public void widgetSelected(SelectionEvent e) {
				result = text.getText();

				shell.dispose();
			}
		});
		shell.setDefaultButton(ok);
	}

	protected static int checkStyle(int style) {
		if ((style & SWT.SYSTEM_MODAL) == SWT.SYSTEM_MODAL) {
			return SWT.SYSTEM_MODAL;
		} else if ((style & SWT.PRIMARY_MODAL) == SWT.PRIMARY_MODAL) {
			return SWT.PRIMARY_MODAL;
		} else if ((style & SWT.APPLICATION_MODAL) == SWT.APPLICATION_MODAL) {
			return SWT.APPLICATION_MODAL;
		}

		return SWT.APPLICATION_MODAL;
	}

	protected static int checkImageStyle(int style) {
		if ((style & SWT.ICON_ERROR) == SWT.ICON_ERROR) {
			return SWT.ICON_ERROR;
		} else if ((style & SWT.ICON_INFORMATION) == SWT.ICON_INFORMATION) {
			return SWT.ICON_INFORMATION;
		} else if ((style & SWT.ICON_QUESTION) == SWT.ICON_QUESTION) {
			return SWT.ICON_QUESTION;
		} else if ((style & SWT.ICON_WARNING) == SWT.ICON_WARNING) {
			return SWT.ICON_WARNING;
		} else if ((style & SWT.ICON_WORKING) == SWT.ICON_WORKING) {
			return SWT.ICON_WORKING;
		}

		return SWT.NONE;
	}

	@Override
	public void setText(String string) {
		super.setText(string);

		shell.setText(string);
	}

	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		if (message == null)
			SWT.error(SWT.ERROR_NULL_ARGUMENT);

		this.message = message;
		label.setText(message);
	}

	public String open() {
		shell.pack();
		shell.open();
		shell.layout();

		while (!shell.isDisposed())
			if (!shell.getDisplay().readAndDispatch())
				shell.getDisplay().sleep();

		return result;
	}
}

/*
 * ***********************************
 * Copyright 2005 Completely Random Solutions * * DISCLAMER: * We are not
 * responsible for any damage * directly or indirectly caused by the usage * of
 * this or any other class in association * with this class. Use at your own
 * risk. * This or any other class by CRS is not * certified for use in life
 * support systems, by * Lockheed Martin engineers, in development * or use of
 * nuclear reactors, weapons of mass * destruction, or in inter-planetary
 * conflict. * (Unless otherwise specified) ************************************
 */
