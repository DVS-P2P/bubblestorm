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

#ifndef BS_APP_H
#define BS_APP_H

#include <string>
#include <vector>

#include "ns3/application.h"

namespace ns3 {

class BSApp : public Application 
{
public:
	static TypeId GetTypeId();

	BSApp();
	virtual ~BSApp();
	
	void SetAppName(const std::string& appName);
	void SetArgs(const std::vector<std::string>& args);
	
// protected:
// 	virtual void DoDispose();

private:
	virtual void StartApplication();
	virtual void StopApplication();

	// attributes
	int m_nodeId;
	std::string m_appName;
	std::vector<std::string> m_args;

	int m_handle;

};

} // namespace ns3

#endif

