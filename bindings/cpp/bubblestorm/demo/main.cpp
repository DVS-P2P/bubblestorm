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


#include <cstdio>
#include "node.cpp"

using namespace std;

int main(int argc, const char** argv)
{
	bsInit(argc, argv);

	printf("Args:\n");
	for (int i = 0; i < argc; i++) {
		printf("\t%d: %s\n", i, argv[i]);
	}
	printf("\n ");

	if (argc < 2) {
		printf("Missing args\n");
		return -1;
	}

	Node* node = new Node(argc, argv);
	printf("Start...\n");

	node->run();

	delete node;
	bsShutdown();

	printf("Done.\n");
	return 0;
}
