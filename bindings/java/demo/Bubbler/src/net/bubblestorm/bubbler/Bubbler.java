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

package net.bubblestorm.bubbler;

import net.bubblestorm.BSError;
import net.bubblestorm.BubbleStorm;
import net.bubblestorm.bubbler.backend.Core;
import net.bubblestorm.bubbler.frontend.swt.SWTMain;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.commons.cli.PosixParser;

public class Bubbler {

	final static String APP_NAME = "bubbler";

	final static Options options = new Options();

	static {
		options.addOption("?", "help", false, "show usage");
		options.addOption("p", "port", true, "local bind port");
		options.addOption("b", "bootstrap", true, "bootstrap node address");
		options.addOption("n", "create", true,
				"create a new network instead of joining in existing one");
		options.addOption("c", "console", false, "don't show GUI");
	}

	static void printHelp() {
		HelpFormatter formatter = new HelpFormatter();
		formatter.printHelp(APP_NAME, options);
	}

	static int parseIntOption(String str, int defVal) throws NumberFormatException {
		return (str != null) ? Integer.parseInt(str) : defVal;
	}

	public static void main(String[] args) throws BSError {
		try {
			// process command line
			CommandLineParser parser = new PosixParser();
			CommandLine cmd = parser.parse(options, args);

			if (cmd.hasOption('?')) {
				printHelp();
				return;
			}

			String bootstrapAddr = cmd.getOptionValue('b');
			int port = parseIntOption(cmd.getOptionValue('p'), -1);
			boolean createRing = cmd.hasOption('n');
			if (createRing) {
				bootstrapAddr = cmd.getOptionValue('n');
				if (port < 0)
					port = 8585;
			}
			final boolean noGui = cmd.hasOption('c');

			// core
			final Core core = new Core();
			System.out.println("Connecting to the network...");
			core.connect(bootstrapAddr, port, createRing, new BubbleStorm.JoinHandler() {
				@Override
				public void onJoinComplete() {
					System.out.println("Connected.");
					if (!noGui) {
						// main window
						try {
							SWTMain swtMain = new SWTMain(core);
							swtMain.run();
						} catch (Throwable t) {
							t.printStackTrace();
						}
						System.out.println("Terminating.");
						core.shutdown();
						System.exit(0);
					}
				}
			});

		} catch (ParseException e) {
			System.err.println(e.getMessage());
			printHelp();
		} catch (NumberFormatException e) {
			e.printStackTrace();
			printHelp();
		}
	}
}
