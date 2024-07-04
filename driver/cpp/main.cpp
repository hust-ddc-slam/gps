
#include "gps.hpp"


#include <iostream>
#include <boost/asio.hpp>
#include <thread>


using namespace std;



int main(void){
    string port_name = "/dev/ttyTHS0";
    cout << "==> Open port: " << port_name << endl;
    GPS gps(port_name);
    cout << "Create a new thread to receive data..." << endl;

    while(1){
        cout << " This is in ros loop" << endl;
        this_thread::sleep_for(chrono::milliseconds(1000));   // sleep 10ms
    }
    return 0;
}

