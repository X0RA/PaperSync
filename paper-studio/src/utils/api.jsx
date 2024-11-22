const API_BASE_URL = import.meta.env.DEV 
    ? `http://localhost:${import.meta.env.SERVER_PORT || '4001'}`
    : '';

export const fetchLayoutFromServer = async () => {
    try {
        const response = await fetch(`${API_BASE_URL}/layout/get-layout`);
        if (!response.ok) {
            throw new Error('Failed to fetch layout');
        }
        return await response.json();
    } catch (error) {
        console.error('Error fetching layout:', error);
        throw error;
    }
};

export const saveLayoutToServer = async (layoutData) => {
    try {
        const response = await fetch(`${API_BASE_URL}/layout/save-layout`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
            },
            body: JSON.stringify(layoutData),
        });
        if (!response.ok) {
            throw new Error('Failed to save layout');
        }
        return await response.json();
    } catch (error) {
        console.error('Error saving layout:', error);
        throw error;
    }
};
