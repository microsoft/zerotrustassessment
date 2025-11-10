import { PageHeader, PageHeaderHeading } from "@/components/page-header";
import { Card, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";

export default function Apps() {
    return (
        <>
            <PageHeader>
                <PageHeaderHeading>Apps</PageHeaderHeading>
            </PageHeader>
            <Card>
                <CardHeader>
                    <CardTitle>Coming soon</CardTitle>
                    <CardDescription>He that can have patience can have what he will. - Benjamin Franklin
                    </CardDescription>
                </CardHeader>
            </Card>
        </>
    )
}
