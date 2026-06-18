const fetch = require('node-fetch');

// Replace with your WaniKani API token
const API_TOKEN = 'YOUR_API_TOKEN';
const API_BASE_URL = 'https://api.wanikani.com/v2';

async function getBurnedKanji() {
    try {
        const response = await fetch(`${API_BASE_URL}/assignments?burned=true&subject_types=kanji`, {
            headers: {
                'Authorization': `Bearer ${API_TOKEN}`,
                'Wanikani-Revision': '20170710'
            }
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const data = await response.json();

        // Get all subject IDs from the assignments
        const subjectIds = data.data.map(assignment => assignment.data.subject_id);

        // Fetch details for each subject
        const subjectsResponse = await fetch(`${API_BASE_URL}/subjects?ids=${subjectIds.join(',')}`, {
            headers: {
                'Authorization': `Bearer ${API_TOKEN}`,
                'Wanikani-Revision': '20170710'
            }
        });

        if (!subjectsResponse.ok) {
            throw new Error(`HTTP error! status: ${subjectsResponse.status}`);
        }

        const subjectsData = await subjectsResponse.json();

        // Print the burned Kanji
        console.log('Your Burned Kanji:');
        console.log('-----------------');
        subjectsData.data.forEach(subject => {
            const kanji = subject.data;
            console.log(`${kanji.characters} - ${kanji.meanings.find(m => m.primary).meaning}`);
        });

    } catch (error) {
        console.error('Error:', error);
    }
}

getBurnedKanji(); 