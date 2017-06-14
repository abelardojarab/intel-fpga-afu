/*
//example mem test usage
RC4Memtest rc4_obj;
RC4State rc4_state;
const int TEST_BUFFER_SIZE	 = (64*1024);
char test_buffer[TEST_BUFFER_SIZE];

rc4_obj.setup_key("mytestkey", 8);
rc4_state = rc4_obj.get_state();
rc4_obj.write_bytes(test_buffer, TEST_BUFFER_SIZE);
rc4_obj.set_state(rc4_state);
test_buffer[1045] = 0;
test_buffer[1042] = 0;
int errors = rc4_obj.check_bytes(test_buffer, TEST_BUFFER_SIZE);
printf("Errors %d - (2 are expected)\n", errors);
*/

#include <stdio.h>
#include <string.h>

#define RC4_SWAP_S(a, b) {rc4_S_type tmp = a; a = b; b = tmp;}

typedef unsigned int rc4_S_type;

class RC4State
{
public:
	int i;
	int j;
	rc4_S_type S[256];
	
	void setup_key(const char *key, int keylength)
	{
		int i;
		for(i = 0; i < 256; i++)
			S[i] = i;
		int j = 0;
		for(i = 0; i < 256; i++)
		{
			j = (j + S[i] + key[i % keylength]) % 256;
			RC4_SWAP_S(S[i], S[j])
		}
		
		this->i = 0;
		this->j = 0;
	}
};

class RC4Memtest
{
public:
	RC4Memtest() {}
	virtual ~RC4Memtest() {}
	
	void setup_key(const char *key)
	{
		setup_key(key, strlen(key));
	}
	
	void setup_key(const char *key, int keylength)
	{
		m_state.setup_key(key, keylength);
	}
	
	char get_byte()
	{
		char buf;	
		write_bytes(&buf, 1);
		return buf;
	}
	
	int check_bytes(char *buf, int length)
	{
		int errors = 0;
		int i = m_state.i;
		int j = m_state.j;
		rc4_S_type K;
		for(int mem_index = 0; mem_index < length; mem_index++)
		{
			i = (i + 1) % 256;
			j = (j + m_state.S[i]) % 256;
			RC4_SWAP_S(m_state.S[i], m_state.S[j])
			K = m_state.S[(m_state.S[i] + m_state.S[j]) % 256];
			if(buf[mem_index] != (char)K)
				errors++;
		}
		
		m_state.i = i;
		m_state.j = j;
		
		return errors;
	}
	
	void write_bytes(char *buf, int length)
	{
		int i = m_state.i;
		int j = m_state.j;
		rc4_S_type K;
		for(int mem_index = 0; mem_index < length; mem_index++)
		{
			i = (i + 1) % 256;
			j = (j + m_state.S[i]) % 256;
			RC4_SWAP_S(m_state.S[i], m_state.S[j])
			K = m_state.S[(m_state.S[i] + m_state.S[j]) % 256];
			buf[mem_index] = (char)K;
		}
		
		m_state.i = i;
		m_state.j = j;
	}
	
	void dump_bytes(int length)
	{
		for(int i = 0; i < length; i++)
		{
			printf("%02x", get_byte() & 0xff);
		}
		printf("\n");
	}
	
	void dump_S()
	{
		for(int i = 0; i < 256; i++)
		{
			printf("%02x", (int)(m_state.S[i] & 0xff));
			if(i != 0 && i % 32 == 31)
				printf("\n");
		}
	}
	
	RC4State &get_state() { return m_state; }
	
	void set_state(RC4State &state) { m_state = state; }
	
private:
	RC4State m_state;
};
