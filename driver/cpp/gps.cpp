
#include "gps.hpp"

#include <thread>
#include <linux/ioctl.h>

using namespace std;

GPS::GPS(std::string dev):portName_(std::move(dev)){
    try{
        sp_ = new serial_port(ioSev_, portName_);
        sp_->set_option(serial_port::baud_rate(115200));
        sp_->set_option(serial_port::flow_control(serial_port::flow_control::none));
        sp_->set_option(serial_port::parity(serial_port::parity::none));
        sp_->set_option(serial_port::stop_bits(serial_port::stop_bits::one));
        sp_->set_option(serial_port::character_size(8));
    }catch (...){
        std::cerr << "Exception Error: Cannot open port: "<<portName_ <<", did run 'chmod' before?"<< std::endl;
    }

    std::cout <<"GPS main process begin..." << std::endl;
    std::thread t1(&GPS::process, this);
    t1.detach();

}

void GPS::process(void){
    while(true){
        uchar dollar[1];        // $ 
        uchar mode[6];          // GNVTG, GNHDT, GPGGA, GPRMC
        boost::asio::streambuf buf;        // REAL data
        uchar check_sum[3];     // sum check, * + 2bytes

        boost::asio::read(*sp_, boost::asio::buffer(dollar, 1));
        // first find the $, and then check GNVTG, GNHDT, GPGGA, GPRMC
        if(dollar[0] == '$'){
            cout << "--> Find `$` " << endl;
            boost::asio::read(*sp_, boost::asio::buffer(mode, 6));
            if (mode[0] == 'G' && mode[1] == 'P' && mode[2] == 'G' && mode[3] == 'G' && mode[4] == 'A' && mode[5] == ','){
                cout << "GPGGA Header get" << endl;
                // process GPGGA
                boost::asio::read_until(*sp_, buf, '*');
                cout << "GPGGA Data get" << endl;
                boost::asio::read(*sp_, boost::asio::buffer(check_sum, 3));
                std::istream is(&buf);
                std::string core_data;
                std::getline(is, core_data, '*'); // Read up to the '*' character
                std::cout << "Received: " << core_data << std::endl;

                // // check sum.
                // uchar checkSum=0;
                // for(int i=0; i<6; ++i){     // GPGGA check.
                //     checkSum ^= mode[i];
                // }
                // for(uchar ch:core_data){
                //     checkSum ^= static_cast<uchar>(ch);
                // }
                // cout <<"Check sum: " << int(checkSum) << endl;
                // cout << "Input sum: " << int(check_sum[1]) << ", " << int(check_sum[2]) << endl;

                parseGPGGA(core_data);
            }
            if (mode[0] == 'G' && mode[1] == 'N' && mode[2] == 'V' && mode[3] == 'T' && mode[4] == 'G' && mode[5] == ','){
                cout << "GNVTG data get" << endl;
            }
            if (mode[0] == 'G' && mode[1] == 'N' && mode[2] == 'H' && mode[3] == 'D' && mode[4] == 'T' && mode[5] == ','){
                cout << "GNHDT data get" << endl;
            }
            if (mode[0] == 'G' && mode[1] == 'P' && mode[2] == 'R' && mode[3] == 'M' && mode[4] == 'C' && mode[5] == ','){
                cout << "GPRMC data get" << endl;
            }
            if (mode[0] == 'G' && mode[1] == 'P' && mode[2] == 'G' && mode[3] == 'G' && mode[4] == 'A' && mode[5] == ','){
                cout << "GPGGA data get" << endl;
            }
        }
        std::this_thread::sleep_for(std::chrono::milliseconds(10));
    }
}




//// GPGGA format:
// GPGGA
// 0 hhmmss.ss: utc time
// 1 llll.ll: ddmm.mmmm, latitude
// 2 a: N or S
// 3 yyyyy.yy: dddmm.mmmm, longtitude
// 4 b: E or W
// 5 q: quality (int)
// 6 x: number of sittelite
// 7 h: HDOP
// 8 M: M(meter)
// 9 m.m: altitude
// 10  M: M(meter)
// 11  sss: (差分GPS数据的年龄（无效时为空）)
// 12  ccc: (差分站ID（无效时为空）)
// *
// sum1, sum2


bool GPS::parseGPGGA(const std::string& raw_gpgga){
    std::stringstream ss(raw_gpgga);
    std::string item;
    std::vector<std::string> parsed_data;

    while (std::getline(ss, item, ',')){
        parsed_data.push_back(item);
    }

    string utc_str = parsed_data[0];
    string lati_str = parsed_data[1];
    string long_str = parsed_data[3];
    string alti_str = parsed_data[9];

    latitude = stod(lati_str.substr(0, 2)) + stod(lati_str.substr(2)) / 60.0f;
    longitude = stod(long_str.substr(0,3)) + stod(long_str.substr(3)) / 60.0f;
    altitude = stod(alti_str);

    satellite_number = stoi(parsed_data[6]);
    mode = stoi(parsed_data[5]);
    hhop = stod(parsed_data[7]);

    cout << "--------------------------- Parsed GPS data: ---------------------------" << endl;
    cout << "(" << latitude << ", " << longitude << ", " << altitude << ")" << endl;
    cout << "Mode: " << mode << endl;
    cout << "Number of satellite: " << satellite_number << endl;
    cout << "hhop: " << hhop << endl;
    cout << "------------------------------------------------------------------------" << endl;

    if(mode != 4){
        cout <<"Warning. Mode not 4" << endl;
        return false;
    }
    if(hhop > 2){
        cout <<"Warning. Bad hhop" << endl;
        return false;
    }
    if(satellite_number < 12){
        cout <<"Warning. Too less satellite" << endl;
        return false;
    }

    return true;
}
