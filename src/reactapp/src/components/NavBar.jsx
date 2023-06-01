import React from "react";
import { useNavigate } from "react-router-dom";
import {
    Button,
} from "@fluentui/react-components";

export const NavBar = () => {
    const navigate = useNavigate();
    return (
        <>
            <ul>
                <li>
                    <Button appearance="secondary" onClick={() => navigate('/')} >Home</Button>
                </li>
            </ul>
        </>
    );
}