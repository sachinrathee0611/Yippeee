document.addEventListener('DOMContentLoaded', () => {
    const timeTimestamp = document.getElementById('deploy-time');
    const currentOptions = { 
        weekday: 'long', 
        year: 'numeric', 
        month: 'long', 
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit',
        timeZoneName: 'short'
    };
    
    // Set current active time as local simulation of render lifecycle
    timeTimestamp.textContent = new Date().toLocaleDateString('en-US', currentOptions);
});