# Public domain.

exec 2>&1
echo 'curve25519 speedreport version 20050915'
echo ''
echo '% uname -a'
uname -a
echo '% echo "$CC"'
echo "$CC"
echo '% gcc --version'
gcc --version
echo '% cat /proc/cpuinfo'
cat /proc/cpuinfo
echo '% sysctl -a hw.model'
sysctl -a hw.model
echo '% /usr/sbin/psrinfo -v'
/usr/sbin/psrinfo -v
echo '% cat x86cpuid.out'
cat x86cpuid.out
echo '% cat curve25519.h cpucycles.h'
cat curve25519.h
echo '% echo _____; ./curve25519-speed; echo _____'
echo _____; ./curve25519-speed; echo _____
echo '% ./test-curve25519 | head -123456 | tail -1'
./test-curve25519 | head -123456 | tail -1
