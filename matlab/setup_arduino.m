function port = setup_arduino()
% SETUP_ARDUINO - Find and return the serial port for the Arduino Mega
%
% Usage:
%   port = setup_arduino();
%   s = serialport(port, 9600);
%
% On macOS, the Arduino Mega typically appears as /dev/cu.usbmodemXXXX
% On Windows, it appears as COMx
% On Linux, it appears as /dev/ttyACMx or /dev/ttyUSBx

    ports = serialportlist("available");

    if isempty(ports)
        error('No serial ports found. Is the Arduino connected via USB?');
    end

    fprintf('Available serial ports:\n');
    for i = 1:length(ports)
        fprintf('  [%d] %s\n', i, ports(i));
    end

    if length(ports) == 1
        port = ports(1);
        fprintf('\nAuto-selected: %s\n', port);
    else
        idx = input('\nSelect port number: ');
        if idx < 1 || idx > length(ports)
            error('Invalid selection.');
        end
        port = ports(idx);
    end

    fprintf('Using port: %s\n', port);
    fprintf('You can now connect with: s = serialport("%s", 9600)\n', port);
end
