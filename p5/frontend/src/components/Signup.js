import React, { useState } from 'react';
import axios from 'axios';
import { useNavigate } from 'react-router-dom';

const Signup = () => {
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');
    const [message, setMessage] = useState('');
    const navigate = useNavigate();

    const handleSignup = async (e) => {
        e.preventDefault();
        try {
            const response = await axios.post('/users/signup', { username, password });
            setMessage(response.data.message);
            const loginResponse = await axios.post('/users/login', { username, password });
            const { user_id } = loginResponse.data;
            localStorage.setItem('user_id', user_id);
            localStorage.setItem('username', username);
            navigate('/dashboard');
        } catch (error) {
            setMessage('Error: ' + (error.response?.data?.error || 'Signup failed.'));
        }
    };

    return (
        <div style={{ margin: '20px' }}>
            <h2>Sign Up</h2>
            <form onSubmit={handleSignup}>
                <input type="text" placeholder="Username" value={username} onChange={(e) => setUsername(e.target.value)} required />
                <input type="password" placeholder="Password" value={password} onChange={(e) => setPassword(e.target.value)} required />
                <button type="submit">Sign Up</button>
            </form>
            {message && <p>{message}</p>}
            <p>
                Already have an account? <a href="/">Login</a>
            </p>
        </div>
    );
};

export default Signup;
